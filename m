Received: by an-out-0708.google.com with SMTP id d33so78645and
        for <linux-mm@kvack.org>; Thu, 31 May 2007 06:41:19 -0700 (PDT)
Message-ID: <2c09dd780705310641j34f5d8b9ga70c02d2c93852c8@mail.gmail.com>
Date: Thu, 31 May 2007 19:11:14 +0530
From: "manjunath k" <kmanjunat@gmail.com>
Subject: Dirty pages changes in linux-2.6
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

 Ive been working on some of the proc filesystem
codes and found that the dirty pages list present in
the struct address_space is being removed from the
linux-2.6 kernel version by the patch

"stop-using-the-address_space-dirty_pages-list.patch"

@@ -327,7 +327,6 @@ struct address_space {
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
 	spinlock_t		tree_lock;	/* and spinlock protecting it */
 	struct list_head	clean_pages;	/* list of clean pages */
-	struct list_head	dirty_pages;	/* list of dirty pages */
 	struct list_head	locked_pages;	/* list of locked pages */
 	struct list_head	io_pages;	/* being prepared for I/O */
 	unsigned long		nrpages;	/* number of total pages */

And ive also noticed that the /proc/pid/statm output displays
the dirty page count as 0.
Eg :
cat /proc/self/statm
1207 100 833 3 0 371 0

My perception is that it is because of the changes in the above mentioned
patch the dirty page count is 0 in linux-2.6.

Please give me some information regarding the same.

-Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
