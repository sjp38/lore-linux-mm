Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C47B7C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6078C20851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rCgV6grF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6078C20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 030316B026A; Sun, 19 May 2019 23:53:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23046B026C; Sun, 19 May 2019 23:53:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9C56B026D; Sun, 19 May 2019 23:53:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D37D6B026A
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so8313697plp.6
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8fBJ35agorKCunTXs811LaBEjUlFt/o9xwPOQhaevY0=;
        b=B2Lv8/A4W7XQ7G1gdoqTh4va6u5Xo2CPnqH5qbYQGy7gMEN8NFy1S9INEc+Zaanptm
         HxQEeXHR7D3TsZM2lra51QoJroPO2qgQHl6lswZAlgu+DFdB7cRj6hlmTMCX/8zzkyiP
         qLINxHf5zD54R3ULLrzuteuwQAYU4ZG9RKjXjeMYW2CdnQDAQNOFvg1OZ0Bd1Rty4uaq
         CV+yGwri7OpmS99iXZqecllo03othyGQRArSzCGWAfOOKbpXn2V7ZjIQN8stss0Eupna
         WeeAK6AJbACody23ltp1x1pmRsjE0KvneGL3bv7C2hbEmOw/gK93zauJdfw4d7YhCDdo
         mz+A==
X-Gm-Message-State: APjAAAVAntLJWC4YtSTzgx3898SxIdhnKcRBhmblP/mbifbm9bm1ZeB8
	UvU3yqVFmWy4Jpjfi7agJPLaieopikbtLI+orb8tOyTMMYGYp3H+m1LBwhn3LVIvf9BMN4UvvHh
	x9ZC+PBkROW27G9IU5LyTmcUfNu1Mf9y1x10bdRrm3D5HkzCcNl6uPYJCbJYO+i8=
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr71910565plr.70.1558324413237;
        Sun, 19 May 2019 20:53:33 -0700 (PDT)
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr71910460plr.70.1558324411631;
        Sun, 19 May 2019 20:53:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324411; cv=none;
        d=google.com; s=arc-20160816;
        b=TMs9ZBFbpRbC6EtEGum7PcnnQjahPAmgkBWUOfRNwNKyJ8FkVnnzKkeenfmmAuWWwy
         VxWc9+fs/T4ckiEmWwdwEDh+uCCPgu6ZcaHCCr4kmvqVkq2VQAeC5sCWAoCgRSgDkR6r
         7NGUgOAJO85igLCPLJLaTKxVagREviBVVPuPJV/UVF/hCkoZhE3CGsr7essYyfDf+RbX
         UkK/57VUNffmCrr7zzVKZDzWq94bGWbR53yRmpxZVmXS9jaE5auLBtKe/DHPwOtE26x9
         kGNN/HXcDIXCT8x6ybdWy4dp9eOpzT9PVe46Br8/ZFtTJF7LhRS5hZVtFeLxmmMX2idb
         us7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=8fBJ35agorKCunTXs811LaBEjUlFt/o9xwPOQhaevY0=;
        b=EOINE7w01q3uTS4GVVxZgpuKQO6Gtu9XTKUAhRlBQ5XrGVY9sme++ZeL2CDbLY54aJ
         3Oc6bV5XzUolwBGo6CQ2XiiXld3Jx9Q9lTkj82b/+uUmvAEWiR57OuOroopVDaXDjx9w
         nlPBXS+zKHSWn9SOK3KR8xtViHZG4tfIrYAG7HgLnBRIvajDNF1d1NTKoIhR5nbUAPNn
         vwBAQZHoSZipNjXKbRykXMq6F0s6Y7DtD0BsP0YjbwKFM8OFTtGY4Yg67GOtNVS2dp40
         UTdwdnGNcOpH8VPNMke4zF7Oij0syAPDluaJdqMYzTVWGeMtNTKRx6Zwik6/iYKRiTvy
         PO9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rCgV6grF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r144sor8495461pgr.57.2019.05.19.20.53.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rCgV6grF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8fBJ35agorKCunTXs811LaBEjUlFt/o9xwPOQhaevY0=;
        b=rCgV6grFd1VFVtus7aOkg2Nhi0kCxqIOMHIRqgpyweiFaeLMopGpQwJXCZSKLwsibC
         QgYt+TXrIKw2sHv+WiiCOfsbLvzeoIvzscG2JiDBvxnBWFBqW/JRMfK5IiyIMerLxj0v
         oKNyq7x5uN0yJc6DDoT8UNzSaWOedLJWVbhMqTVfpBBauFJz6d1py2+RYNYursmwonRB
         9Ia1hQqeDHdslM+lJrbutkWYR5BmmcZdz7nZslS804Sd9V71hpb0Q89SJWPb0d/+qXQZ
         8Iy+Iee1ApriyJSBoamNpeHPHSspH0yPc0PAoQ/N9QX4UN5TXeHvXsjvosacyIOHPyW0
         URWA==
X-Google-Smtp-Source: APXvYqyIBN0roIeUPC55CImKizlJCrfGac023V5GGgyvYa8R+Rw3Iny1vz3vJBv5Ytczunh6wQZSpg==
X-Received: by 2002:a63:191b:: with SMTP id z27mr73201987pgl.327.1558324411188;
        Sun, 19 May 2019 20:53:31 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:30 -0700 (PDT)
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
Subject: [RFC 6/7] mm: extend process_madvise syscall to support vector arrary
Date: Mon, 20 May 2019 12:52:53 +0900
Message-Id: <20190520035254.57579-7-minchan@kernel.org>
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

Currently, process_madvise syscall works for only one address range
so user should call the syscall several times to give hints to
multiple address range.

This patch extends process_madvise syscall to support multiple
hints, address ranges and return vaules so user could give hints
all at once.

struct pr_madvise_param {
    int size;                       /* the size of this structure */
    const struct iovec __user *vec; /* address range array */
}

int process_madvise(int pidfd, ssize_t nr_elem,
		    int *behavior,
		    struct pr_madvise_param *results,
		    struct pr_madvise_param *ranges,
		    unsigned long flags);

- pidfd

target process fd

- nr_elem

the number of elemenent of array behavior, results, ranges

- behavior

hints for each address range in remote process so that user could
give different hints for each range.

- results

array of buffers to get results for associated remote address range
action.

- ranges

array to buffers to have remote process's address ranges to be
processed

- flags

extra argument for the future. It should be zero this moment.

Example)

struct pr_madvise_param {
        int size;
        const struct iovec *vec;
};

int main(int argc, char *argv[])
{
        struct pr_madvise_param retp, rangep;
        struct iovec result_vec[2], range_vec[2];
        int hints[2];
        long ret[2];
        void *addr[2];

        pid_t pid;
        char cmd[64] = {0,};
        addr[0] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
                          MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);

        if (MAP_FAILED == addr[0])
                return 1;

        addr[1] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
                          MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);

        if (MAP_FAILED == addr[1])
                return 1;

        hints[0] = MADV_COLD;
	range_vec[0].iov_base = addr[0];
        range_vec[0].iov_len = ALLOC_SIZE;
        result_vec[0].iov_base = &ret[0];
        result_vec[0].iov_len = sizeof(long);
	retp.vec = result_vec;
        retp.size = sizeof(struct pr_madvise_param);

        hints[1] = MADV_COOL;
        range_vec[1].iov_base = addr[1];
        range_vec[1].iov_len = ALLOC_SIZE;
        result_vec[1].iov_base = &ret[1];
        result_vec[1].iov_len = sizeof(long);
        rangep.vec = range_vec;
        rangep.size = sizeof(struct pr_madvise_param);

        pid = fork();
        if (!pid) {
                sleep(10);
        } else {
                int pidfd = open(cmd,  O_DIRECTORY | O_CLOEXEC);
                if (pidfd < 0)
                        return 1;

                /* munmap to make pages private for the child */
                munmap(addr[0], ALLOC_SIZE);
                munmap(addr[1], ALLOC_SIZE);
                system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
                if (syscall(__NR_process_madvise, pidfd, 2, behaviors,
						&retp, &rangep, 0))
                        perror("process_madvise fail\n");
                system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
        }

        return 0;
}

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/uapi/asm-generic/mman-common.h |   5 +
 mm/madvise.c                           | 184 +++++++++++++++++++++----
 2 files changed, 166 insertions(+), 23 deletions(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index b9b51eeb8e1a..b8e230de84a6 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -74,4 +74,9 @@
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
 				 PKEY_DISABLE_WRITE)
 
+struct pr_madvise_param {
+	int size;			/* the size of this structure */
+	const struct iovec __user *vec;	/* address range array */
+};
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index af02aa17e5c1..f4f569dac2bd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -320,6 +320,7 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
 	struct page *page;
 	struct vm_area_struct *vma = walk->vma;
 	unsigned long next;
+	long nr_pages = 0;
 
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
@@ -380,9 +381,12 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
 
 		ptep_test_and_clear_young(vma, addr, pte);
 		deactivate_page(page);
+		nr_pages++;
+
 	}
 
 	pte_unmap_unlock(orig_pte, ptl);
+	*(long *)walk->private += nr_pages;
 	cond_resched();
 
 	return 0;
@@ -390,11 +394,13 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
 
 static void madvise_cool_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end)
+			     unsigned long addr, unsigned long end,
+			     long *nr_pages)
 {
 	struct mm_walk cool_walk = {
 		.pmd_entry = madvise_cool_pte_range,
 		.mm = vma->vm_mm,
+		.private = nr_pages
 	};
 
 	tlb_start_vma(tlb, vma);
@@ -403,7 +409,8 @@ static void madvise_cool_page_range(struct mmu_gather *tlb,
 }
 
 static long madvise_cool(struct vm_area_struct *vma,
-			unsigned long start_addr, unsigned long end_addr)
+			unsigned long start_addr, unsigned long end_addr,
+			long *nr_pages)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
@@ -413,7 +420,7 @@ static long madvise_cool(struct vm_area_struct *vma,
 
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
-	madvise_cool_page_range(&tlb, vma, start_addr, end_addr);
+	madvise_cool_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
 	tlb_finish_mmu(&tlb, start_addr, end_addr);
 
 	return 0;
@@ -429,6 +436,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 	int isolated = 0;
 	struct vm_area_struct *vma = walk->vma;
 	unsigned long next;
+	long nr_pages = 0;
 
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
@@ -492,7 +500,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 		list_add(&page->lru, &page_list);
 		if (isolated >= SWAP_CLUSTER_MAX) {
 			pte_unmap_unlock(orig_pte, ptl);
-			reclaim_pages(&page_list);
+			nr_pages += reclaim_pages(&page_list);
 			isolated = 0;
 			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 			orig_pte = pte;
@@ -500,19 +508,22 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 	}
 
 	pte_unmap_unlock(orig_pte, ptl);
-	reclaim_pages(&page_list);
+	nr_pages += reclaim_pages(&page_list);
 	cond_resched();
 
+	*(long *)walk->private += nr_pages;
 	return 0;
 }
 
 static void madvise_cold_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end)
+			     unsigned long addr, unsigned long end,
+			     long *nr_pages)
 {
 	struct mm_walk warm_walk = {
 		.pmd_entry = madvise_cold_pte_range,
 		.mm = vma->vm_mm,
+		.private = nr_pages,
 	};
 
 	tlb_start_vma(tlb, vma);
@@ -522,7 +533,8 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
 
 
 static long madvise_cold(struct vm_area_struct *vma,
-			unsigned long start_addr, unsigned long end_addr)
+			unsigned long start_addr, unsigned long end_addr,
+			long *nr_pages)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
@@ -532,7 +544,7 @@ static long madvise_cold(struct vm_area_struct *vma,
 
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
-	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
+	madvise_cold_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
 	tlb_finish_mmu(&tlb, start_addr, end_addr);
 
 	return 0;
@@ -922,7 +934,7 @@ static int madvise_inject_error(int behavior,
 static long
 madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
 		struct vm_area_struct **prev, unsigned long start,
-		unsigned long end, int behavior)
+		unsigned long end, int behavior, long *nr_pages)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -930,9 +942,9 @@ madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_COOL:
-		return madvise_cool(vma, start, end);
+		return madvise_cool(vma, start, end, nr_pages);
 	case MADV_COLD:
-		return madvise_cold(vma, start, end);
+		return madvise_cold(vma, start, end, nr_pages);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(tsk, vma, prev, start,
@@ -981,7 +993,7 @@ madvise_behavior_valid(int behavior)
 }
 
 static int madvise_core(struct task_struct *tsk, unsigned long start,
-			size_t len_in, int behavior)
+			size_t len_in, int behavior, long *nr_pages)
 {
 	unsigned long end, tmp;
 	struct vm_area_struct *vma, *prev;
@@ -996,6 +1008,7 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
 
 	if (start & ~PAGE_MASK)
 		return error;
+
 	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
 
 	/* Check to see whether len was rounded up from small -ve to zero */
@@ -1035,6 +1048,8 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
 	blk_start_plug(&plug);
 	for (;;) {
 		/* Still start < end. */
+		long pages = 0;
+
 		error = -ENOMEM;
 		if (!vma)
 			goto out;
@@ -1053,9 +1068,11 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(tsk, vma, &prev, start, tmp, behavior);
+		error = madvise_vma(tsk, vma, &prev, start, tmp,
+					behavior, &pages);
 		if (error)
 			goto out;
+		*nr_pages += pages;
 		start = tmp;
 		if (prev && start < prev->vm_end)
 			start = prev->vm_end;
@@ -1140,26 +1157,137 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	return madvise_core(current, start, len_in, behavior);
+	unsigned long dummy;
+
+	return madvise_core(current, start, len_in, behavior, &dummy);
 }
 
-SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
-		size_t, len_in, int, behavior)
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
+static int process_madvise_core(struct task_struct *tsk, int *behaviors,
+				struct iov_iter *iter,
+				const struct iovec *range_vec,
+				unsigned long riovcnt,
+				unsigned long flags)
+{
+	int i;
+	long err;
+
+	for (err = 0, i = 0; i < riovcnt && iov_iter_count(iter); i++) {
+		long ret = 0;
+
+		err = madvise_core(tsk, (unsigned long)range_vec[i].iov_base,
+				range_vec[i].iov_len, behaviors[i],
+				&ret);
+		if (err)
+			ret = err;
+
+		if (copy_to_iter(&ret, sizeof(long), iter) !=
+				sizeof(long)) {
+			err = -EFAULT;
+			break;
+		}
+
+		err = 0;
+	}
+
+	return err;
+}
+
+SYSCALL_DEFINE6(process_madvise, int, pidfd, ssize_t, nr_elem,
+			const int __user *, hints,
+			struct pr_madvise_param __user *, results,
+			struct pr_madvise_param __user *, ranges,
+			unsigned long, flags)
 {
 	int ret;
 	struct fd f;
 	struct pid *pid;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
+	struct pr_madvise_param result_p, range_p;
+	const struct iovec __user *result_vec, __user *range_vec;
+	int *behaviors;
+	struct iovec iovstack_result[UIO_FASTIOV];
+	struct iovec iovstack_r[UIO_FASTIOV];
+	struct iovec *iov_l = iovstack_result;
+	struct iovec *iov_r = iovstack_r;
+	struct iov_iter iter;
+
+	if (flags != 0)
+		return -EINVAL;
+
+	ret = pr_madvise_copy_param(results, &result_p);
+	if (ret)
+		return ret;
+
+	ret = pr_madvise_copy_param(ranges, &range_p);
+	if (ret)
+		return ret;
+
+	result_vec = result_p.vec;
+	range_vec = range_p.vec;
+
+	if (result_p.size != sizeof(struct pr_madvise_param) ||
+			range_p.size != sizeof(struct pr_madvise_param))
+		return -EINVAL;
+
+	behaviors = kmalloc_array(nr_elem, sizeof(int), GFP_KERNEL);
+	if (!behaviors)
+		return -ENOMEM;
+
+	ret = copy_from_user(behaviors, hints, sizeof(int) * nr_elem);
+	if (ret < 0)
+		goto free_behavior_vec;
+
+	ret = import_iovec(READ, result_vec, nr_elem, UIO_FASTIOV,
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
+				UIO_FASTIOV, iovstack_r, &iov_r);
+	if (ret <= 0)
+		goto free_iovecs;
 
 	f = fdget(pidfd);
-	if (!f.file)
-		return -EBADF;
+	if (!f.file) {
+		ret = -EBADF;
+		goto free_iovecs;
+	}
 
 	pid = pidfd_to_pid(f.file);
 	if (IS_ERR(pid)) {
 		ret = PTR_ERR(pid);
-		goto err;
+		goto put_fd;
 	}
 
 	ret = -EINVAL;
@@ -1167,7 +1295,7 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
 	tsk = pid_task(pid, PIDTYPE_PID);
 	if (!tsk) {
 		rcu_read_unlock();
-		goto err;
+		goto put_fd;
 	}
 	get_task_struct(tsk);
 	rcu_read_unlock();
@@ -1176,12 +1304,22 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
 		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
 		if (ret == -EACCES)
 			ret = -EPERM;
-		goto err;
+		goto put_task;
 	}
-	ret = madvise_core(tsk, start, len_in, behavior);
+
+	ret = process_madvise_core(tsk, behaviors, &iter, iov_r,
+					nr_elem, flags);
 	mmput(mm);
+put_task:
 	put_task_struct(tsk);
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
2.21.0.1020.gf2820cf01a-goog

