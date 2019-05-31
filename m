Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3403CC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:44:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4188264AC
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:43:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XKSLVIvf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4188264AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0E36B0280; Fri, 31 May 2019 02:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74B3C6B0281; Fri, 31 May 2019 02:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB546B0282; Fri, 31 May 2019 02:43:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23B4B6B0280
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:43:59 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so5635609pla.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:43:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/qxKh5Sd2cIvdmEp7qaPCDBJLZKehHIzssQM7btjaog=;
        b=G+TlR7gIMYdz3YClQV2+zxjLB4JkKpoYZDUZqOhhWL5ni1+8TG2Ae7z4dcwTM8XQiG
         6XayZ9isbD+4HaQABXG9ek8IUUzTwilB/1FwR+9n+zLh89fmkSupk3LS5Hte2rB9fQPJ
         FxPgAZCFTrZl7GWaFYPym2xxIBmLLbZmFbGJw8s60o6RgJbEHRRveM9uAuNi3dQb+SKw
         VLOwQ8knVHVAoReP6hccBULQdiZBEDsNB7KiwnYxPw7mO30pOpQN/K2bwkuJytnsxMPA
         GljxCNlZTpbmiVkgYDNDWwkz0T94/2pX+/uZV2fp8D6xvKA552CMAV4LoeoEMlKtHgHw
         W8lg==
X-Gm-Message-State: APjAAAW5KriXb0ExtAeF31tEMSC28OTnOAHaklLKyUuad+Sa3rhJpFla
	M7R4lpNCq+sjLkqrjbGN6N6lKuUO4YbDqtbKrFYhewozGr1t1+FwsWyiwsxgtRCFU4n7HS/htUc
	3bkNWN9GVQx0JVYDGEHsvCU+AHYdWVxyjufUAkOLTRjoYMly2jlIJdulBGR80Yfg=
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr7289149plo.225.1559285038697;
        Thu, 30 May 2019 23:43:58 -0700 (PDT)
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr7289095plo.225.1559285037506;
        Thu, 30 May 2019 23:43:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559285037; cv=none;
        d=google.com; s=arc-20160816;
        b=XxNBlu4xEQRZt/g5QavIrtJOBp2JJnbD+Fiszd+H49LwnUpxqp7lXrb86Ta5oY6hfw
         nC8OrVI+opd4jmQxwwt9g7A1hC469IHVWjFjUivnoO5oygoAr26iTmqE9l+tq/7mdckO
         liKkoJsCuhFarIS1wIMZKM56uQMXws56+ndCOPD829IuBFz7lsxHbhqz3K6M/cs3HT1n
         yS2WCIwNCObZl7Si6dsbtepiEV5/b4eRlwuWq8CLYmJwpVFgFWruFkcgsjBjvQfo1PA8
         NW2H9JT3EfX2SUj9+oTC9bdDIiLmp2WG119aSjIVQGPWD80KVELgXTpuprJTJfqt60YD
         FH9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=/qxKh5Sd2cIvdmEp7qaPCDBJLZKehHIzssQM7btjaog=;
        b=GfYsDoIItB2PhuDyZmFwCmPjwIAxnJpfeufmPrVDpE1Xjmf2Qml3UK9mHmQ6K3Eqrq
         gfqAoCWOU3d6zmJjJ5rGMhkWvvOU2QRclw8aJmWkL4wrHVt8hZghNDEvHV0VV3eb2YR9
         0tRaw6R8qZlESdPko+qjRshiGRbhDa3eJ8fo+DpP/pYstA4AyrNWxt/iJ+295daKtNoU
         Zh1nGoQoKN8xv8iZ34DQt7YYMsRRTje5LsifHAmlfQRhEgOKlns5672o1KlByGqFyXYF
         5Zyd0TQPXe8XZzdXDfsiIgBYJMxaMI4/BwVlwc+DU9XddsAG2wcPFzlJHZGLBx8m0lcr
         j9iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XKSLVIvf;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c34sor5310485pgb.8.2019.05.30.23.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 23:43:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XKSLVIvf;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/qxKh5Sd2cIvdmEp7qaPCDBJLZKehHIzssQM7btjaog=;
        b=XKSLVIvfbXFduytLOVRRP+7q+9eS6PVclnbre5yWnQ2ulCLxJC+U5oTgFrMnEQeNAf
         eObYAkBLjnRSzHgTxAR+qO9wGvvMLR3l+58XoqDjZMnGJfBLDCohcRa+VL/pMmst2VY4
         4NkoKyOpgPaQD2AXu7CZdNs05heoLQwWvAkOuals+tANzP9I5itzGEWwaCCbkenvjrvJ
         zOGFz0MIxeC+wowv/sL3U66m0bBSBW18XeLnISIVwaWJ+wBJrsGidFeXsm7kIBiocmUs
         KUvffuUdYxn8vMi33LZVCZZLRY7+2tTmRHigoExmUp4G51N8eW2O35cDsDY4ftA9G0P8
         Iu8w==
X-Google-Smtp-Source: APXvYqxG5/PbTB6PPKuzAXJIcjNhgNf6ZhMN+PpfuPfgq3fEGC9dwq5i1uswo13q01oJzXIAx3/6Uw==
X-Received: by 2002:a63:2ad2:: with SMTP id q201mr7003061pgq.94.1559285037009;
        Thu, 30 May 2019 23:43:57 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f30sm4243340pjg.13.2019.05.30.23.43.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:43:55 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	Minchan Kim <minchan@kernel.org>
Subject: [RFCv2 6/6] mm: extend process_madvise syscall to support vector arrary
Date: Fri, 31 May 2019 15:43:13 +0900
Message-Id: <20190531064313.193437-7-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
In-Reply-To: <20190531064313.193437-1-minchan@kernel.org>
References: <20190531064313.193437-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, process_madvise syscall works for only one address range so
user should call the syscall several times to give hints to multiple
address ranges. However, it's not efficient to support atomicity of
address range opreations as well as performance perspective.

This patch extends process_madvise syscall to support multiple hints,
address ranges and return vaules so user could give hints all at once.

struct pr_madvise_param {
        int size;               /* the size of this structure */
        int cookie;             /* reserved to support atomicity */
        int nr_elem;            /* count of below arrary fields */
        int __user *hints;      /* hints for each range */
        /* to store result of each operation */
        const struct iovec __user *results;
        /* input address ranges */
        const struct iovec __user *ranges;
};

  int process_madvise(int pidfd, struct pr_madvise_param *u_param,
			unsigned long flags);

About cookie, Daniel Colascione suggested a idea[1] to support atomicity
as well as improving parsing speed of address ranges of the target process.
The process_getinfo(2) syscall could create vma configuration sequence
number and returns(e.g., the seq number will be increased when target process
holds mmap_sem exclusive lock) the number with address ranges as binary form.
With calling the this vector syscall with the sequence number and address
ranges we got from process_getinfo, we could detect there was race of
the target process address space layout and makes the fail of the syscall
if user want to have atomicity. It also speed up the address range
parsing because we don't need to parse human-friend strings from /proc fs.

[1] https://lore.kernel.org/lkml/20190520035254.57579-1-minchan@kernel.org/T/#m7694416fd179b2066a2c62b5b139b14e3894e224

struct pr_madvise_param {
    int size;               /* the size of this structure */
    int cookie;             /* reserved to support atomicity */
    int nr_elem;            /* count of below arrary fields */
    int *hints;      /* hints for each range */
    /* to store result of each operation */
    const struct iovec *results;
    /* input address ranges */
    const struct iovec *ranges;
};

int main(int argc, char *argv[])
{
        struct pr_madvise_param param;
        int hints[NR_ADDR_RANGE];
        int ret[NR_ADDR_RANGE];
        struct iovec ret_vec[NR_ADDR_RANGE];
        struct iovec range_vec[NR_ADDR_RANGE];
        void *addr[NR_ADDR_RANGE];
        pid_t pid;

        addr[0] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
                          MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
        if (MAP_FAILED == addr[0]) {
                printf("Fail to alloc\n");
                return 1;
        }

        addr[1] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
                          MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);

        if (MAP_FAILED == addr[1]) {
                printf("Fail to alloc\n");
                return 1;
        }

        ret_vec[0].iov_base = &ret[0];
        ret_vec[0].iov_len = sizeof(long);
        ret_vec[1].iov_base = &ret[1];
        ret_vec[1].iov_len = sizeof(long);
        range_vec[0].iov_base = addr[0];
        range_vec[0].iov_len = ALLOC_SIZE;
        range_vec[1].iov_base = addr[1];
        range_vec[1].iov_len = ALLOC_SIZE;

        hints[0] = MADV_COLD;
        hints[1] = MADV_PAGEOUT;

        param.size = sizeof(struct pr_madvise_param);
        param.cookie = 0;
        param.nr_elem = NR_ADDR_RANGE;
        param.hints = hints;
        param.results = ret_vec;
        param.ranges = range_vec;

        pid = fork();
        if (!pid) {
                sleep(10);
        } else {
                int pidfd = syscall(__NR_pidfd_open, pid, 0);
                if (pidfd < 0) {
                        printf("Fail to open process file descriptor\n");
                        return 1;
                }

                munmap(addr[0], ALLOC_SIZE);
                munmap(addr[1], ALLOC_SIZE);

                system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
                if (syscall(__NR_process_madvise, pidfd, &param, 0))
                        perror("process_madvise fail\n");
                system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
        }

	return 0;
}

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/syscalls.h               |   6 +-
 include/uapi/asm-generic/mman-common.h |  11 +++
 mm/madvise.c                           | 126 ++++++++++++++++++++++---
 3 files changed, 126 insertions(+), 17 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 6ba081c955f6..05627718a547 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -872,9 +872,9 @@ asmlinkage long sys_munlockall(void);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
-asmlinkage long sys_process_madvise(int pidfd, unsigned long start,
-				size_t len, int behavior,
-				unsigned long cookie, unsigned long flags);
+asmlinkage long sys_process_madvise(int pidfd,
+				struct pr_madvise_param __user *u_params,
+				unsigned long flags);
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 			unsigned long prot, unsigned long pgoff,
 			unsigned long flags);
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 92e347a89ddc..220c2b5eb961 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -75,4 +75,15 @@
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
 				 PKEY_DISABLE_WRITE)
 
+struct pr_madvise_param {
+	int size;		/* the size of this structure */
+	int cookie;		/* reserved to support atomicity */
+	int nr_elem;		/* count of below arrary fields */
+	int __user *hints;	/* hints for each range */
+	/* to store result of each operation */
+	const struct iovec __user *results;
+	/* input address ranges */
+	const struct iovec __user *ranges;
+};
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index fd205e928a1b..94d782097afd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -1107,6 +1107,56 @@ static int madvise_core(struct task_struct *task, struct mm_struct *mm,
 	return error;
 }
 
+static int pr_madvise_copy_param(struct pr_madvise_param __user *u_param,
+		struct pr_madvise_param *param)
+{
+	u32 size;
+	int ret;
+
+	memset(param, 0, sizeof(*param));
+
+	ret = get_user(size, &u_param->size);
+	if (ret)
+		return ret;
+
+	if (size > PAGE_SIZE)
+		return -E2BIG;
+
+	if (!size || size > sizeof(struct pr_madvise_param))
+		return -EINVAL;
+
+	ret = copy_from_user(param, u_param, size);
+	if (ret)
+		return -EFAULT;
+
+	return ret;
+}
+
+static int process_madvise_core(struct task_struct *tsk, struct mm_struct *mm,
+				int *behaviors,
+				struct iov_iter *iter,
+				const struct iovec *range_vec,
+				unsigned long riovcnt)
+{
+	int i;
+	long err;
+
+	for (i = 0; i < riovcnt && iov_iter_count(iter); i++) {
+		err = -EINVAL;
+		if (process_madvise_behavior_valid(behaviors[i]))
+			err = madvise_core(tsk, mm,
+				(unsigned long)range_vec[i].iov_base,
+				range_vec[i].iov_len, behaviors[i]);
+
+		if (copy_to_iter(&err, sizeof(long), iter) !=
+				sizeof(long)) {
+			return -EFAULT;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * The madvise(2) system call.
  *
@@ -1173,37 +1223,78 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	return madvise_core(current, current->mm, start, len_in, behavior);
 }
 
-SYSCALL_DEFINE6(process_madvise, int, pidfd, unsigned long, start,
-		size_t, len_in, int, behavior, unsigned long, cookie,
-		unsigned long, flags)
+
+SYSCALL_DEFINE3(process_madvise, int, pidfd,
+				struct pr_madvise_param __user *, u_params,
+				unsigned long, flags)
 {
 	int ret;
 	struct fd f;
 	struct pid *pid;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	struct pr_madvise_param params;
+	const struct iovec __user *result_vec, __user *range_vec;
+	int *behaviors;
+	struct iovec iovstack_result[UIO_FASTIOV];
+	struct iovec iovstack_r[UIO_FASTIOV];
+	struct iovec *iov_l = iovstack_result;
+	struct iovec *iov_r = iovstack_r;
+	struct iov_iter iter;
+	int nr_elem;
 
 	if (flags != 0)
 		return -EINVAL;
 
+	ret = pr_madvise_copy_param(u_params, &params);
+	if (ret)
+		return ret;
+
 	/*
-	 * We don't support cookie to gaurantee address space change
-	 * atomicity yet.
+	 * We don't support cookie to gaurantee address space atomicity yet.
+	 * Once we implment cookie, process_madvise_core need to hold mmap_sme
+	 * during entire operation to guarantee atomicity.
 	 */
-	if (cookie != 0)
+	if (params.cookie != 0)
 		return -EINVAL;
 
-	if (!process_madvise_behavior_valid(behavior))
-		return return -EINVAL;
+	range_vec = params.ranges;
+	result_vec = params.results;
+	nr_elem = params.nr_elem;
+
+	behaviors = kmalloc_array(nr_elem, sizeof(int), GFP_KERNEL);
+	if (!behaviors)
+		return -ENOMEM;
+
+	ret = copy_from_user(behaviors, params.hints, sizeof(int) * nr_elem);
+	if (ret < 0)
+		goto free_behavior_vec;
+
+	ret = import_iovec(READ, result_vec, params. nr_elem, UIO_FASTIOV,
+				&iov_l, &iter);
+	if (ret < 0)
+		goto free_behavior_vec;
+
+	if (!iov_iter_count(&iter)) {
+		ret = -EINVAL;
+		goto free_iovecs;
+	}
+
+	ret = rw_copy_check_uvector(CHECK_IOVEC_ONLY, range_vec, nr_elem,
+					UIO_FASTIOV, iovstack_r, &iov_r);
+	if (ret <= 0)
+		goto free_iovecs;
 
 	f = fdget(pidfd);
-	if (!f.file)
-		return -EBADF;
+	if (!f.file) {
+		ret = -EBADF;
+		goto free_iovecs;
+	}
 
 	pid = pidfd_pid(f.file);
 	if (IS_ERR(pid)) {
 		ret = PTR_ERR(pid);
-		goto err;
+		goto put_fd;
 	}
 
 	rcu_read_lock();
@@ -1211,7 +1302,7 @@ SYSCALL_DEFINE6(process_madvise, int, pidfd, unsigned long, start,
 	if (!task) {
 		rcu_read_unlock();
 		ret = -ESRCH;
-		goto err;
+		goto put_fd;
 	}
 
 	get_task_struct(task);
@@ -1225,11 +1316,18 @@ SYSCALL_DEFINE6(process_madvise, int, pidfd, unsigned long, start,
 		goto release_task;
 	}
 
-	ret = madvise_core(task, mm, start, len_in, behavior);
+	ret = process_madvise_core(task, mm, behaviors, &iter, iov_r, nr_elem);
 	mmput(mm);
 release_task:
 	put_task_struct(task);
-err:
+put_fd:
 	fdput(f);
+free_iovecs:
+	if (iov_r != iovstack_r)
+		kfree(iov_r);
+	kfree(iov_l);
+free_behavior_vec:
+	kfree(behaviors);
+
 	return ret;
 }
-- 
2.22.0.rc1.257.g3120a18244-goog

