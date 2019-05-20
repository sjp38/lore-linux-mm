Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD535C46476
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8894C21537
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YQSNJCcK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8894C21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 253F06B0269; Sun, 19 May 2019 23:53:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DBA76B026A; Sun, 19 May 2019 23:53:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D0F6B026B; Sun, 19 May 2019 23:53:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEE9C6B0269
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d12so9057150pfn.9
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tBNcU7dtCYU00dN9icFSaU4lVFSngUnu9jAK5Jk7lkE=;
        b=mx9FYVkLnGuvqeNtVcNiguNTB84p7riKFg+ZHXehdFQKEdgpfXoK6ZOgcIo1kTcrxq
         dNkdE7d+ideKF4dYn1hHusAACQ9sbBgHUt2dKRyuRtpPw9w36yAjnOFLD9IlGIcINakB
         7rgWC/WaZOdZkdgKPKRxe8ObGbIy/2dpoByGJ6DwRlOMLsHSLypbGfiJIOQMFCa/tVtB
         pLuoL65z+8/Prc5SPGmVfH9V5Ic1YlNoAn8nEOjkDTMQr3MeMRUI/24u1pGVFQm4u0ap
         THuzZesgz6NRa06Hz4ccMyeYYT3/o0jamMZIhcQg5Qu7GUDZfFZkQp8sSZhwSK/pYbh6
         04TA==
X-Gm-Message-State: APjAAAWVaucu14103Lt4WD/p2pFrmxznVbktwzjedHaQGomLwrj3Rinc
	yBXc8CIXq8aS7f/6tWaEqe/H4KgcSnkNMd/NtPiDdDw228zJtAjNPcGAK65Q/keDqa9wgGverRG
	BB0yVOR2abRPVOMhMzhaG35Nq5Ickgjo4VaHes5b3B027HrZBUCwUS+lW/36SpL0=
X-Received: by 2002:a17:902:aa95:: with SMTP id d21mr18674364plr.32.1558324408413;
        Sun, 19 May 2019 20:53:28 -0700 (PDT)
X-Received: by 2002:a17:902:aa95:: with SMTP id d21mr18674291plr.32.1558324407133;
        Sun, 19 May 2019 20:53:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324407; cv=none;
        d=google.com; s=arc-20160816;
        b=YeG8D4TkeBkiELMQhrZPVAOR8ycwXr1Tr/1Uk0C8D7ILJOWLgL3Y2P7HSc4bX4M9Wu
         afCt6QOlx9AVvG6jW14kLceaLCQyDgiydfnEJvlnidbI2wPWfAWJlPXGzuc8kL5qTDl3
         wK3rjTiX1hB+CwfNVBMdEQR4eh35pSl2Fe9L79iPdrPBQ8yL1EuiUCvIGsaOMVei7Ffe
         9h+EdeaFYXdd/ivNLvWb9y/hsFUJZbifeWqetInxEou/W9ssIq/CzCJ+s6ztKIE3i39W
         1Z7ZQ1lbtniGyeRKIhHc+iECJFn5bDkc8z3XZwsMM/imoJDPd2qRCIdeIVcSuUNewYil
         OERg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=tBNcU7dtCYU00dN9icFSaU4lVFSngUnu9jAK5Jk7lkE=;
        b=L8fuCmOYLJ4n67JKi8axX6MCNcGe3D/Q0IeUaFUTfYe1MqVU91dSM19MCKxSzj57c4
         bH9eDZKfxpMCnsxJNWMAz0IJO3GHYAjopGIAxNE/NrySb8+2O1bXt+EoaGcK6VVMFxRN
         khHxj3c+msPKX9Yxb/ke7s/J4ajVbpSmk7/owhCt5RX8Gx3qhlqLuZwa0xTzhh3zA8fY
         OrFFlO+G/IMONQezh91ji38vdf+qC0abxlehce23kAUoRWx3li5vadB3MFR+HXmMN4+m
         IVeYisYUNvl7vBs17noH4IR5bTB22a8JZVakASGxjx5pnVB7dzj2oW0eaPKXVb0cB28U
         HSeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YQSNJCcK;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l96sor17798691plb.68.2019.05.19.20.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YQSNJCcK;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=tBNcU7dtCYU00dN9icFSaU4lVFSngUnu9jAK5Jk7lkE=;
        b=YQSNJCcKM7WviKLmz7cKDDQ551lYaqh3ka6GsuFVnMdhbAJcv5YeKKfABVLz6AGuTW
         lFwJDX545/UN4fmoPbQeKDAZHe7/rEVNOLkNgOXnk53Csp4rl3Oqoo0kakKoxaazkCvK
         VE3q0cT/ObPibPKiSEqZT2szzLJ0aonUfjZNoXz0b8B6u5vrQ9WKCNKjliUntgNQCH1m
         Zo3b+x+OCfxBYocbwx2ZWCMM9CR6/OqkPVpXyc4meEXyXm8MM3GplEZqHq/yOb81G/8y
         LBK0MmgHyiXKvDiNOpYqZgcuTxYGuGePMZ2bth3KXF8BznuDHuYyyQT7YwG2mvugxbqV
         P8gg==
X-Google-Smtp-Source: APXvYqz0+fnAnbc+xIx6Hyu1xzjAmscoSixfuxLRBCh1WPSoZBvSNF0PxhRQ0cIpCPfHKg1QdL/lIA==
X-Received: by 2002:a17:902:b490:: with SMTP id y16mr44075401plr.161.1558324406751;
        Sun, 19 May 2019 20:53:26 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:25 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [RFC 5/7] mm: introduce external memory hinting API
Date: Mon, 20 May 2019 12:52:52 +0900
Message-Id: <20190520035254.57579-6-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is some usecase that centralized userspace daemon want to give
a memory hint like MADV_[COOL|COLD] to other process. Android's
ActivityManagerService is one of them.

It's similar in spirit to madvise(MADV_WONTNEED), but the information
required to make the reclaim decision is not known to the app. Instead,
it is known to the centralized userspace daemon(ActivityManagerService),
and that daemon must be able to initiate reclaim on its own without
any app involvement.

To solve the issue, this patch introduces new syscall process_madvise(2)
which works based on pidfd so it could give a hint to the exeternal
process.

int process_madvise(int pidfd, void *addr, size_t length, int advise);

All advises madvise provides can be supported in process_madvise, too.
Since it could affect other process's address range, only privileged
process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
gives it the right to ptrrace the process could use it successfully.

Please suggest better idea if you have other idea about the permission.

* from v1r1
  * use ptrace capability - surenb, dancol

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/x86/entry/syscalls/syscall_32.tbl |  1 +
 arch/x86/entry/syscalls/syscall_64.tbl |  1 +
 include/linux/proc_fs.h                |  1 +
 include/linux/syscalls.h               |  2 ++
 include/uapi/asm-generic/unistd.h      |  2 ++
 kernel/signal.c                        |  2 +-
 kernel/sys_ni.c                        |  1 +
 mm/madvise.c                           | 45 ++++++++++++++++++++++++++
 8 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 4cd5f982b1e5..5b9dd55d6b57 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -438,3 +438,4 @@
 425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
 426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
 427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
+428	i386	process_madvise		sys_process_madvise		__ia32_sys_process_madvise
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 64ca0d06259a..0e5ee78161c9 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -355,6 +355,7 @@
 425	common	io_uring_setup		__x64_sys_io_uring_setup
 426	common	io_uring_enter		__x64_sys_io_uring_enter
 427	common	io_uring_register	__x64_sys_io_uring_register
+428	common	process_madvise		__x64_sys_process_madvise
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 52a283ba0465..f8545d7c5218 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -122,6 +122,7 @@ static inline struct pid *tgid_pidfd_to_pid(const struct file *file)
 
 #endif /* CONFIG_PROC_FS */
 
+extern struct pid *pidfd_to_pid(const struct file *file);
 struct net;
 
 static inline struct proc_dir_entry *proc_net_mkdir(
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e2870fe1be5b..21c6c9a62006 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -872,6 +872,8 @@ asmlinkage long sys_munlockall(void);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
+asmlinkage long sys_process_madvise(int pid_fd, unsigned long start,
+				size_t len, int behavior);
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 			unsigned long prot, unsigned long pgoff,
 			unsigned long flags);
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index dee7292e1df6..7ee82ce04620 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
 __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
 #define __NR_io_uring_register 427
 __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
+#define __NR_process_madvise 428
+__SYSCALL(__NR_process_madvise, sys_process_madvise)
 
 #undef __NR_syscalls
 #define __NR_syscalls 428
diff --git a/kernel/signal.c b/kernel/signal.c
index 1c86b78a7597..04e75daab1f8 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3620,7 +3620,7 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
 	return copy_siginfo_from_user(kinfo, info);
 }
 
-static struct pid *pidfd_to_pid(const struct file *file)
+struct pid *pidfd_to_pid(const struct file *file)
 {
 	if (file->f_op == &pidfd_fops)
 		return file->private_data;
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 4d9ae5ea6caf..5277421795ab 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -278,6 +278,7 @@ COND_SYSCALL(mlockall);
 COND_SYSCALL(munlockall);
 COND_SYSCALL(mincore);
 COND_SYSCALL(madvise);
+COND_SYSCALL(process_madvise);
 COND_SYSCALL(remap_file_pages);
 COND_SYSCALL(mbind);
 COND_SYSCALL_COMPAT(mbind);
diff --git a/mm/madvise.c b/mm/madvise.c
index 119e82e1f065..af02aa17e5c1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -9,6 +9,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/page_idle.h>
+#include <linux/proc_fs.h>
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
@@ -16,6 +17,7 @@
 #include <linux/hugetlb.h>
 #include <linux/falloc.h>
 #include <linux/sched.h>
+#include <linux/sched/mm.h>
 #include <linux/ksm.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -1140,3 +1142,46 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
 	return madvise_core(current, start, len_in, behavior);
 }
+
+SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
+		size_t, len_in, int, behavior)
+{
+	int ret;
+	struct fd f;
+	struct pid *pid;
+	struct task_struct *tsk;
+	struct mm_struct *mm;
+
+	f = fdget(pidfd);
+	if (!f.file)
+		return -EBADF;
+
+	pid = pidfd_to_pid(f.file);
+	if (IS_ERR(pid)) {
+		ret = PTR_ERR(pid);
+		goto err;
+	}
+
+	ret = -EINVAL;
+	rcu_read_lock();
+	tsk = pid_task(pid, PIDTYPE_PID);
+	if (!tsk) {
+		rcu_read_unlock();
+		goto err;
+	}
+	get_task_struct(tsk);
+	rcu_read_unlock();
+	mm = mm_access(tsk, PTRACE_MODE_ATTACH_REALCREDS);
+	if (!mm || IS_ERR(mm)) {
+		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
+		if (ret == -EACCES)
+			ret = -EPERM;
+		goto err;
+	}
+	ret = madvise_core(tsk, start, len_in, behavior);
+	mmput(mm);
+	put_task_struct(tsk);
+err:
+	fdput(f);
+	return ret;
+}
-- 
2.21.0.1020.gf2820cf01a-goog

