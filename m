Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D3AB8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 15:40:38 -0500 (EST)
Date: Sat, 5 Mar 2011 21:31:59 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v4 4/4] exec: document acct_arg_size()
Message-ID: <20110305203159.GE7546@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com> <20110303114952.B94B.A69D9226@jp.fujitsu.com> <20110303154706.GA22560@redhat.com> <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com> <20110305203040.GA7546@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110305203040.GA7546@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>, Linus Torvalds <torvalds@linux-foundation.org>

Add the comment to explain acct_arg_size().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---

 fs/exec.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- 38/fs/exec.c~4_doc_acct_arg_size	2011-03-05 21:23:15.000000000 +0100
+++ 38/fs/exec.c	2011-03-05 21:23:33.000000000 +0100
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
