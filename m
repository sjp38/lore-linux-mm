Date: Tue, 15 Oct 2002 00:57:33 -0500
From: Matt Reppert <arashi@arashi.yi.org>
Subject: [PATCH] Compile without xattrs
Message-Id: <20021015005733.3bbde222.arashi@arashi.yi.org>
In-Reply-To: <3DABA351.7E9C1CFB@digeo.com>
References: <3DABA351.7E9C1CFB@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

On Mon, 14 Oct 2002 22:10:41 -0700
Andrew Morton <akpm@digeo.com> wrote:

> - merge up the ext2/3 extended attribute code, convert that to use
>   the slab shrinking API in Linus's current tree.

Trivial patch for the "too chicken to enable xattrs for now" case, but I
need this to compile:

--- linux-2.5-orig/include/linux/ext2_xattr.h	2002-10-15 00:47:03 -0500
+++ linux-2.5/include/linux/ext2_xattr.h	2002-10-15 00:45:48 -0500
@@ -92,20 +92,20 @@
 ext2_xattr_get(struct inode *inode, int name_index,
 	       const char *name, void *buffer, size_t size)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline int
 ext2_xattr_list(struct inode *inode, char *buffer, size_t size)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline int
 ext2_xattr_set(struct inode *inode, int name_index, const char *name,
 	       const void *value, size_t size, int flags)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline void
--- linux-2.5-orig/include/linux/ext3_xattr.h	2002-10-15 00:49:59.000000000 -0500
+++ linux-2.5/include/linux/ext3_xattr.h	2002-10-15 00:50:12.000000000 -0500
@@ -92,20 +92,20 @@
 ext3_xattr_get(struct inode *inode, int name_index, const char *name,
 	       void *buffer, size_t size, int flags)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline int
 ext3_xattr_list(struct inode *inode, void *buffer, size_t size, int flags)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline int
 ext3_xattr_set(handle_t *handle, struct inode *inode, int name_index,
 	       const char *name, const void *value, size_t size, int flags)
 {
-	return -ENOTSUP;
+	return -ENOTSUPP;
 }
 
 static inline void


Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
