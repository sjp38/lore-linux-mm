Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 295776B00C6
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:26 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 36/60] c/r: add generic '->checkpoint()' f_op to simple devices
Date: Wed, 22 Jul 2009 05:59:58 -0400
Message-Id: <1248256822-23416-37-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

* /dev/null
* /dev/zero
* /dev/random
* /dev/urandom

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 drivers/char/mem.c    |    2 ++
 drivers/char/random.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index afa8813..828ba7f 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -799,6 +799,7 @@ static const struct file_operations null_fops = {
 	.read		= read_null,
 	.write		= write_null,
 	.splice_write	= splice_write_null,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 #ifdef CONFIG_DEVPORT
@@ -815,6 +816,7 @@ static const struct file_operations zero_fops = {
 	.read		= read_zero,
 	.write		= write_zero,
 	.mmap		= mmap_zero,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 /*
diff --git a/drivers/char/random.c b/drivers/char/random.c
index 8c74448..211ca70 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1164,6 +1164,7 @@ const struct file_operations random_fops = {
 	.poll  = random_poll,
 	.unlocked_ioctl = random_ioctl,
 	.fasync = random_fasync,
+	.checkpoint = generic_file_checkpoint,
 };
 
 const struct file_operations urandom_fops = {
@@ -1171,6 +1172,7 @@ const struct file_operations urandom_fops = {
 	.write = random_write,
 	.unlocked_ioctl = random_ioctl,
 	.fasync = random_fasync,
+	.checkpoint = generic_file_checkpoint,
 };
 
 /***************************************************************
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
