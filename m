Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5625C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 832782084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xu1YD8L3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 832782084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A5A46B0007; Fri, 26 Apr 2019 00:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12D046B0008; Fri, 26 Apr 2019 00:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0F086B000A; Fri, 26 Apr 2019 00:48:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B363F6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:48:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b7so1183570plb.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=19ht8iIxjpdUCy46Bwuc2JuWjKgwjDNE0u0Rezv/IEc=;
        b=XHWPITKRwpAqGm448dNN+03pul3T7rCRE8NxaxLPqzxQNaDq+xPpe90JJ/HtV7dtGb
         fnRen2NJMP36JFaKkd7asxP6YzCT9eVfzkBNu/jjjQVUtmSnvh3yYWxd4sIKQwO0dxhB
         DPp4mgOJiguBE29fx5fpiv6Qez6jkgJkQYAjlQW0zvL17b4X8P0M2HuZ8KKYVQAM5OIm
         +xpcv4kmCu6pORrkSIgUz24wQhudNdM2abqej7GCADLG6LSkf+LahKjInMYx0+vhpp5s
         kXjC5BqHyP53fKGVRFzfnqE3RYPyTGQpilfdau2Ep47PNrnr2vatVq/oZ447VzEKOPHi
         cedA==
X-Gm-Message-State: APjAAAV5niixmBrMtN9iQhfLj6RxM7ycdnip55vy+yd8rdsEoe8r17OV
	KMzaZY1W4hWuM6kcU9lRBnmn4F1H/FFidJRDomfIwfoSs++Rq5rHAt4sP/7YJlOE/VZkrTIaw0t
	PS72viEXSxVnu8Age5CnIkAoxuOb7i8DYqObcfu7SoB/7ANpMIH7DMhWdK6ej5GGtRw==
X-Received: by 2002:a17:902:758b:: with SMTP id j11mr6395781pll.87.1556254127371;
        Thu, 25 Apr 2019 21:48:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzckWI56WHq27pzbI/QvJQZbRibLduEOkHQ2YsD+lzGNihHwD3ZVEuDqwIseqga/QIdsUMH
X-Received: by 2002:a17:902:758b:: with SMTP id j11mr6395730pll.87.1556254126558;
        Thu, 25 Apr 2019 21:48:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254126; cv=none;
        d=google.com; s=arc-20160816;
        b=08JFoDyYRFL2LYyoDgx531iNBSt1T+m1TijczsDps69/LxuKe1VswGttgG3bGpeRGo
         xtGgHVWi7M2WEIDPnyC0hjwya+ccM2BBAm1nUXWDSRRqI4ZucERZacd0J05PIKw8NGgE
         yW36E3TdtospyLQr+vFXJms7MK3Xg94R/uE5Rh0oOXWs56k9O2GPPn6fppeN9Z0Te5wD
         1R49/JLpg484GDqczyl36RmmcXP+5fatcbv/qJXgdIW9GpTJSgXtU2C3r9kZ8ey6jHDd
         CUDaf96jYzphHX6cRZoG/5udC4yIpwvU3Da4uttgmbXYXZVLu6qsj0vV2iI2BmYPednB
         2xAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=19ht8iIxjpdUCy46Bwuc2JuWjKgwjDNE0u0Rezv/IEc=;
        b=wCvww8PoQc7NXqEEJzldq9jfmSuipV5t0hsJZkTTBG8E2LdXE6OF9W+2Wkp2phXbnZ
         +MDtAZ3M2ZhoR6q7zfcneKJZlnifatV1DH7J1w6Jx3cogOt0+NSGCVNcbjM5ljTKNHFv
         uPLYgv8oVOp9FdbGB7osKS7/HsaIyibYG5W1m206CHrGeKlRCeKzrnx/sxECM+gExkwf
         jvdXhM1AZqi+3wIOcNZQDFCp7lN23+kFoQaUIfcq+1sQnyYXIXRHCaAmQ79o3gjRyWDA
         tNB0koVQ1FFAdgnwEiQxXAdNL2xZja99wQF7FXaKWh2ZDJXiZolWrC4so4SYVmbdkkAc
         ySTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xu1YD8L3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p87si24683393pfa.77.2019.04.25.21.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:48:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xu1YD8L3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C5340206BF;
	Fri, 26 Apr 2019 04:48:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556254126;
	bh=Ox+Y5IVzZOibAizInYePC8HNxAhtSsNglxPm0imJqsw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Xu1YD8L32ot7k/kZjyHf4o5i2M9MLdf0U+K2crR7e4/Dr+EADl1vEEi2ztXu3NPzV
	 tU4SLUX2H/5Uunbi0YvJWmyECZ7QNrFBGrhNjaFnCMBnBgWerCXDb6WdhE03HuiRZm
	 r8aerdE0gSm8hWuPsLskDSX1UWTSyLbKr6eIgBCw=
Date: Thu, 25 Apr 2019 21:48:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, zhong jiang
 <zhongjiang@huawei.com>, syzkaller-bugs@googlegroups.com,
 syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu
 <peterx@redhat.com>, Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 1/2] userfaultfd: use RCU to free the task struct when
 fork fails
Message-Id: <20190425214845.92be0f66d59121543a87bd09@linux-foundation.org>
In-Reply-To: <20190327084912.GC11927@dhcp22.suse.cz>
References: <20190325225636.11635-1-aarcange@redhat.com>
	<20190325225636.11635-2-aarcange@redhat.com>
	<20190326085643.GG28406@dhcp22.suse.cz>
	<20190327001616.GB15679@redhat.com>
	<20190327084912.GC11927@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This patch is presently stuck.  AFAICT we just need a changelog update
to reflect Michal's observations?



From: Andrea Arcangeli <aarcange@redhat.com>
Subject: userfaultfd: use RCU to free the task struct when fork fails

MEMCG depends on the task structure not to be freed under rcu_read_lock()
in get_mem_cgroup_from_mm() after it dereferences mm->owner.

An alternate possible fix would be to defer the delivery of the
userfaultfd contexts to the monitor until after fork() is guaranteed to
succeed.  Such a change would require more changes because it would create
a strict ordering dependency where the uffd methods would need to be
called beyond the last potentially failing branch in order to be safe. 
This solution as opposed only adds the dependency to common code to set
mm->owner to NULL and to free the task struct that was pointed by
mm->owner with RCU, if fork ends up failing.  The userfaultfd methods can
still be called anywhere during the fork runtime and the monitor will keep
discarding orphaned "mm" coming from failed forks in userland.

This race condition couldn't trigger if CONFIG_MEMCG was set =n at build
time.

Link: http://lkml.kernel.org/r/20190325225636.11635-2-aarcange@redhat.com
Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: zhong jiang <zhongjiang@huawei.com>
Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Jann Horn <jannh@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org>
Cc: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/fork.c |   34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

--- a/kernel/fork.c~userfaultfd-use-rcu-to-free-the-task-struct-when-fork-fails
+++ a/kernel/fork.c
@@ -952,6 +952,15 @@ static void mm_init_aio(struct mm_struct
 #endif
 }
 
+static __always_inline void mm_clear_owner(struct mm_struct *mm,
+					   struct task_struct *p)
+{
+#ifdef CONFIG_MEMCG
+	if (mm->owner == p)
+		WRITE_ONCE(mm->owner, NULL);
+#endif
+}
+
 static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 {
 #ifdef CONFIG_MEMCG
@@ -1331,6 +1340,7 @@ static struct mm_struct *dup_mm(struct t
 free_pt:
 	/* don't put binfmt in mmput, we haven't got module yet */
 	mm->binfmt = NULL;
+	mm_init_owner(mm, NULL);
 	mmput(mm);
 
 fail_nomem:
@@ -1662,6 +1672,24 @@ static inline void rcu_copy_process(stru
 #endif /* #ifdef CONFIG_TASKS_RCU */
 }
 
+#ifdef CONFIG_MEMCG
+static void __delayed_free_task(struct rcu_head *rhp)
+{
+	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
+
+	free_task(tsk);
+}
+#endif /* CONFIG_MEMCG */
+
+static __always_inline void delayed_free_task(struct task_struct *tsk)
+{
+#ifdef CONFIG_MEMCG
+	call_rcu(&tsk->rcu, __delayed_free_task);
+#else /* CONFIG_MEMCG */
+	free_task(tsk);
+#endif /* CONFIG_MEMCG */
+}
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -2123,8 +2151,10 @@ bad_fork_cleanup_io:
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
-	if (p->mm)
+	if (p->mm) {
+		mm_clear_owner(p->mm, p);
 		mmput(p->mm);
+	}
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
@@ -2155,7 +2185,7 @@ bad_fork_cleanup_count:
 bad_fork_free:
 	p->state = TASK_DEAD;
 	put_task_stack(p);
-	free_task(p);
+	delayed_free_task(p);
 fork_out:
 	spin_lock_irq(&current->sighand->siglock);
 	hlist_del_init(&delayed.node);
_

