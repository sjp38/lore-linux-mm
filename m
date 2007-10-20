Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l9KI8xtQ013366
	for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:08:59 -0700
Received: from rv-out-0910.google.com (rvfb22.prod.google.com [10.140.179.22])
	by zps38.corp.google.com with ESMTP id l9KI8wFg009175
	for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:08:58 -0700
Received: by rv-out-0910.google.com with SMTP id b22so668379rvf
        for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:08:58 -0700 (PDT)
Message-ID: <b040c32a0710201108r70822a8m5fc1286f17083605@mail.gmail.com>
Date: Sat, 20 Oct 2007 11:08:58 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] hugetlb: allow sticky directory mount option
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Allow sticky directory mount option for hugetlbfs.  This allows admin
to create a shared hugetlbfs mount point for multiple users, while
prevent accidental file deletion that users may step on each other.
It is similiar to default tmpfs mount option, or typical option used
on /tmp.


Signed-off-by: Ken Chen <kenchen@google.com>


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 12aca8e..d4951f6 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -769,7 +769,7 @@ hugetlbfs_parse_options(char *options
 		case Opt_mode:
 			if (match_octal(&args[0], &option))
  				goto bad_val;
-			pconfig->mode = option & 0777U;
+			pconfig->mode = option & 01777U;
 			break;

 		case Opt_size: {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
