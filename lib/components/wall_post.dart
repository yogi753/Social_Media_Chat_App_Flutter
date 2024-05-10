//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/comment.dart';
import 'package:flutter_app/components/comment_button.dart';
import 'package:flutter_app/components/delete_button.dart';
import 'package:flutter_app/components/like_button.dart';
import 'package:flutter_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  //final String time;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
   // required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {

//user
final currentUser = FirebaseAuth.instance.currentUser!;
bool isLiked = false;

//comment text controller
final _commentTextController = TextEditingController();

@override
void initState(){
  super.initState();
  isLiked = widget.likes.contains(currentUser.email);
}

//toggle like
void toggleLike(){
  setState(() {
    isLiked = !isLiked;
  });

//Access the document is firebase
DocumentReference postRef = 
     FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
if (isLiked)
{
  //if the post is now liked, add the user's email to the 'likes' field
  postRef.update({
    'Likes':FieldValue.arrayUnion([currentUser.email])
  });
} 
else
{
  //if the post is now unliked, remove the user's email to the 'likes' field
  postRef.update({
    'Likes':FieldValue.arrayRemove([currentUser.email])
  });
 }
}

//add a comment
void addComment(String commentText){
   // write the comment to firestore under the comments collection for this post
   FirebaseFirestore.instance
       .collection("User Posts")
       .doc(widget.postId)
       .collection("Comments")
       .add({
      "CommentText" : commentText,
      "CommentedBy" : currentUser.email,
      "CommentTime" : Timestamp.now() //remember to format this when displaying
    });
  }

//show a dialog box for adding comment
void showCommentDialog(){
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text("Add Comment"),
      content: TextField(
        controller: _commentTextController,
        decoration: InputDecoration(hintText: "Write a comment.."),
      ),
      actions: [
       

        //cancel button
        TextButton(
          onPressed: () {
            //pop box
            Navigator.pop(context);

            //clear controller
            _commentTextController.clear();
          },
          child: Text("Cancel"),
        ),

         //post button
        TextButton(
          onPressed: () {
            //add comment
            addComment(_commentTextController.text);

            //pop box
            Navigator.pop(context);

            //clear controller
            _commentTextController.clear();
          },
          child: Text("Post"),
        ),
      ],
    ),
  );
}

// delete a post
// show a dialog box asking for confirmation before deleting the post
void deletePost(){
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: const Text("Delete Post"),
      content: const Text("Are you  sure you want to delete this post?"),
      actions: [
        //CANCEL BUTTON
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel"),
        ),

        //DELETE BUTTON
         TextButton(
          onPressed: () async {

            //delete the comments from firestore first
            //(if you only delete the post, the comments will still be stored in firestore)
            final commentDocs = await FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .get();

            for (var doc in commentDocs.docs){
              await FirebaseFirestore.instance
                 .collection("User Posts")
                 .doc(widget.postId)
                 .collection("Comments")
                 .doc(doc.id)
                 .delete();
            }

            //then delete the post
            FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .delete()
                .then((value) => print("post deleted"))
                .catchError(
                  (error) => print("failed to delete post: $error"));
            
            //dismiss the dialog
            Navigator.pop(context);

          }, 
          child: const Text("Delete"),
        ),
      ],     
    ),
  ); 
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
    ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [  
                 
          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // group of text (message + user email)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                   //message
                  Text(widget.message),
              
                  const SizedBox(height: 5),
              
                  // user
                 Row(
                  children: [
                    Text(
                      widget.user,
                      style: TextStyle(color: Colors.grey[400]),
                  ),
                    Text(
                      " . ",
                      style: TextStyle(color: Colors.grey[400]),
                  ),
                    Text(
                      widget.time,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),

          // delete button
          if (widget.user == currentUser.email)
          DeleteButton(onTap: deletePost),

          ],
        ),

           const SizedBox(height: 20),

          // buttons
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // LIKE
           Column(
            children: [
               //like button
               LikeButton(
                isLiked: isLiked, 
                onTap: toggleLike,
              ),

              const SizedBox(height: 5),

              //likes count
              Text(
                widget.likes.length.toString(),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(width: 10),

            // COMMENT
           Column(
            children: [
               //comment button
               CommentButton(onTap: showCommentDialog),

              const SizedBox(height: 5),

              // comment count
              Text(
                '0',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 20),

      //comments under the post
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
           .collection("User Posts")
           .doc(widget.postId)
           .collection("Comments")
           .orderBy("CommentTime", descending: true)
           .snapshots(), 
        builder: (context, snapshot) {

          //show loading circle if no data yet
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            shrinkWrap: true,  // for nested lists
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((doc){
              // get the comment
              final commentData = doc.data() as Map<String, dynamic>;

              // return the comment
              return Comment(
                text: commentData["CommentText"], 
                user: commentData["CommentedBy"], 
                time: formatDate(commentData["CommentTime"]),
             );
            }).toList(),
          );
        },
      )

        ],
      ),
    );
  }
}