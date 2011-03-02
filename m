Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CFE868D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 11:36:47 -0500 (EST)
Date: Wed, 2 Mar 2011 17:28:12 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v3 4/4] exec: document acct_arg_size()
Message-ID: <20110302162812.GE26810@redhat.com>
References: <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com> <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com> <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com> <AANLkTikVecxcGoZ9a4hmkoi4wynrNfH9_AU7Vb+hOvbH@mail.gmail.com> <20110302162650.GA26810@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110302162650.GA26810@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

Add the comment to explain acct_arg_size().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- 38/fs/exec.c~4_doc_acct_arg_size	2011-03-02 16:21:57.000000000 +0100
+++ 38/fs/exec.c	2011-03-02 16:27:24.000000000 +0100
@@ -164,7 +164,12 @@ out:
 }
 
 #ifdef CONFIG_MMU
-
+/*
+ * The nascent bprm->mm is not visible until exec_mmap() but it can
+ * use a lot of memory, account these pages in current->mm temporary
+ * for oom_badness()->get_mm_rss(). Once exec succeeds or fails, we
+ * change the counter back via acct_arg_size(0).
+ */
 static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
 {
 	struct mm_struct *mm = current->mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
