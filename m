Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.9 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE067C46478
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 23:36:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0FA1208E3
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 23:36:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="auuXTBi0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0FA1208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364386B0006; Fri, 28 Jun 2019 19:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 314118E0003; Fri, 28 Jun 2019 19:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2034E8E0002; Fri, 28 Jun 2019 19:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id DB22C6B0006
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 19:36:56 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id i26so4816430pfo.22
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 16:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BxQTWfA+pGOhec8YtZRoZCqOQIjDs3oLABCnEe7lVs8=;
        b=ADXLxAkpuXZiwy+a39ZjuZecMXNlPly+lOCYjOt6vfHN82JYOnSx9/sqhd0tkFmO71
         od2xZHlHn/PvaNxSEFeAwQ6bzDpfyz2Bm8utXHVK/VxdRcNzjQdnLp9JFXiLq6Yb/rcI
         EmFBqTV3HUfdc48b7c5sN2Ft+PIpTWR++k7P2yXke7N4L8MttDcWYUqffDpO4hWnyzYL
         gySu8cy0OSR4WohdDTTWtkikJak65p6hL9yGXY4nTxPk+pPy6nhXyLZKePe5znkUw2qc
         0YHeLaYUV2kWlBsfRzQadlMe4sPPkRn4BqtgRV5GReG4lvoaLme3N9T5gilWAikhR4q/
         Ao9A==
X-Gm-Message-State: APjAAAWZBxaHclp0EkE+UYFqCyHlHLWonc1YQgD4NM+Puso9SbGAKasK
	GLyhNu40DqWXsVzksR7izGuzC14RZwGWMEyd/BUSqBjf1RLplsS9fT0otUMUi2PCn31WUDrIkIE
	/nTe2M0Z+fn4QvP0LONMef/sarONIs6kaLZ6S7JzwyOHuq8HyofDLQrK3/WbXGbI=
X-Received: by 2002:a63:1950:: with SMTP id 16mr11661266pgz.312.1561765016292;
        Fri, 28 Jun 2019 16:36:56 -0700 (PDT)
X-Received: by 2002:a63:1950:: with SMTP id 16mr11661205pgz.312.1561765015219;
        Fri, 28 Jun 2019 16:36:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561765015; cv=none;
        d=google.com; s=arc-20160816;
        b=lhP6DMf/V1nCrUrjHH5g72+BYx9LW56mAkMNkYyoXeqK0SSKXEZwA00dF5GAZbtzXM
         fMjgRPjGSE0UGEzc2YyUMKJOCVe0uVOM00CB7vGHjO0fsxqIKpqt2yb2NtPzGNkxZ6DJ
         fJmtlZLdsX53CCaeFFyVq2rk9SoaBR6Jqgr+VJQ0a4gLgJl+jz2Il4iswEm3M3kQnD2T
         9br1GTBYBA90/t/C6wNyNMmrvlO78sBfy+qA8g3HB6oNo8N9aFbsfPANPQsmIUnCyasO
         20uYbIXec6ybu5ecihPndgCNCTxvO/szikohJQL6TO6jG1iTvhc4lEvFHXyMH2+rDP+K
         X99w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=BxQTWfA+pGOhec8YtZRoZCqOQIjDs3oLABCnEe7lVs8=;
        b=KZSUwLgHb/TywwUeRwuDbu6dYPnIrQLeS0wIJGNWxOm62oaKDZoD2vnIy/XHyAOHSb
         8hxUSB+KB4R2jBMSlidHG3Ha656mbYndb/Uqw+lBvwT6vezb0F3GN1nzvcCYj0QEU/0G
         qVici5Udqcrg96AmgB2E9DF1PIpIXA5thZ14CHORdnYq+0BxTeKteULfNNXRQ1fk/4O6
         e7/VjRTPUPdYBPZ/ubNgKdTYlClvyNo/t1rOLInX24nI4abZgp7tCKFgUI08i6G6tWqN
         QhAUjDKPTTRYrdYESdrg+PaGacz0LLlPNlKteb3Lmf39aAb2milAwFS2xyWwo772ghd6
         vcOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=auuXTBi0;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor2530582pjy.12.2019.06.28.16.36.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 16:36:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=auuXTBi0;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BxQTWfA+pGOhec8YtZRoZCqOQIjDs3oLABCnEe7lVs8=;
        b=auuXTBi0OjtKxWrH6Z3+ZW5VWnMWC6MyYHZdeISAPOpSLTyB8RUQFmGSHZANYSK8sL
         ZnaWUnCkCqne6SiUqPvtHM3O4f305i+872md+ubiJXwxGQYiWpZQt9kcDO33GfyfVOCb
         yt2T3T5OebQxZxX4o8WmFo+TCa2T2bOA4sE21sMc6tTeSbU0R4vbRzO1DDpqWS9XJf1P
         4YvM54FHkNj7qnCaGOTTAUF41xC4qhKfL9HH/nS0O0hnkbfe4eVShgq+qn2ZukU74l/W
         l44AF/kdt2XxL+kTkgOoQuRQ1QJcueUSY5Cg/4pKEQeThBwvCTVejKG0GOYmiFUR5J6N
         zeXw==
X-Google-Smtp-Source: APXvYqy6BAp377tyW2awFGUZjqd5vEeQlSty8FfgKNggWq4FLk2DqkghXvhSoGtrMG4be/LVo/TnDw==
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr16232020pjw.85.1561765014755;
        Fri, 28 Jun 2019 16:36:54 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id p1sm3470593pff.74.2019.06.28.16.36.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 16:36:53 -0700 (PDT)
Date: Sat, 29 Jun 2019 08:36:49 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628233649.GB245333@google.com>
References: <20190619080835.GA68312@google.com>
 <20190628111627.GA107040@google.com>
 <20190628143201.GB17212@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628143201.GB17212@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:32:01AM -0400, Johannes Weiner wrote:
> On Fri, Jun 28, 2019 at 07:16:27PM +0800, Kuo-Hsin Yang wrote:
> > When file refaults are detected and there are many inactive file pages,
> > the system never reclaim anonymous pages, the file pages are dropped
> > aggressively when there are still a lot of cold anonymous pages and
> > system thrashes.  This issue impacts the performance of applications
> > with large executable, e.g. chrome.
> 
> This is good.
> 
> > Commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache
> > workingset transition") introduced actual_reclaim parameter.  When file
> > refaults are detected, inactive_list_is_low() may return different
> > values depends on the actual_reclaim parameter.  Vmscan would only scan
> > active/inactive file lists at file thrashing state when the following 2
> > conditions are satisfied.
> > 
> > 1) inactive_list_is_low() returns false in get_scan_count() to trigger
> >    scanning file lists only.
> > 2) inactive_list_is_low() returns true in shrink_list() to allow
> >    scanning active file list.
> > 
> > This patch makes the return value of inactive_list_is_low() independent
> > of actual_reclaim and rename the parameter back to trace.
> 
> This is not. The root cause for the problem you describe isn't the
> patch you point to. The root cause is our decision to force-scan the
> file LRU based on relative inactive:active size alone, without taking
> file thrashing into account at all. This is a much older problem.
> 
> After the referenced patch, we're taking thrashing into account when
> deciding whether to deactivate active file pages or not. To solve the
> problem pointed out here, we can extend that same principle to the
> decision whether to force-scan files and skip the anon LRUs.
> 
> The patch you're pointing to isn't the culprit. On the contrary, it
> provides the infrastructure to solve a much older problem.
> 
> > The problem can be reproduced by the following test program.
> > 
> > ---8<---
> > void fallocate_file(const char *filename, off_t size)
> > {
> > 	struct stat st;
> > 	int fd;
> > 
> > 	if (!stat(filename, &st) && st.st_size >= size)
> > 		return;
> > 
> > 	fd = open(filename, O_WRONLY | O_CREAT, 0600);
> > 	if (fd < 0) {
> > 		perror("create file");
> > 		exit(1);
> > 	}
> > 	if (posix_fallocate(fd, 0, size)) {
> > 		perror("fallocate");
> > 		exit(1);
> > 	}
> > 	close(fd);
> > }
> > 
> > long *alloc_anon(long size)
> > {
> > 	long *start = malloc(size);
> > 	memset(start, 1, size);
> > 	return start;
> > }
> > 
> > long access_file(const char *filename, long size, long rounds)
> > {
> > 	int fd, i;
> > 	volatile char *start1, *end1, *start2;
> > 	const int page_size = getpagesize();
> > 	long sum = 0;
> > 
> > 	fd = open(filename, O_RDONLY);
> > 	if (fd == -1) {
> > 		perror("open");
> > 		exit(1);
> > 	}
> > 
> > 	/*
> > 	 * Some applications, e.g. chrome, use a lot of executable file
> > 	 * pages, map some of the pages with PROT_EXEC flag to simulate
> > 	 * the behavior.
> > 	 */
> > 	start1 = mmap(NULL, size / 2, PROT_READ | PROT_EXEC, MAP_SHARED,
> > 		      fd, 0);
> > 	if (start1 == MAP_FAILED) {
> > 		perror("mmap");
> > 		exit(1);
> > 	}
> > 	end1 = start1 + size / 2;
> > 
> > 	start2 = mmap(NULL, size / 2, PROT_READ, MAP_SHARED, fd, size / 2);
> > 	if (start2 == MAP_FAILED) {
> > 		perror("mmap");
> > 		exit(1);
> > 	}
> > 
> > 	for (i = 0; i < rounds; ++i) {
> > 		struct timeval before, after;
> > 		volatile char *ptr1 = start1, *ptr2 = start2;
> > 		gettimeofday(&before, NULL);
> > 		for (; ptr1 < end1; ptr1 += page_size, ptr2 += page_size)
> > 			sum += *ptr1 + *ptr2;
> > 		gettimeofday(&after, NULL);
> > 		printf("File access time, round %d: %f (sec)\n", i,
> > 		       (after.tv_sec - before.tv_sec) +
> > 		       (after.tv_usec - before.tv_usec) / 1000000.0);
> > 	}
> > 	return sum;
> > }
> > 
> > int main(int argc, char *argv[])
> > {
> > 	const long MB = 1024 * 1024;
> > 	long anon_mb, file_mb, file_rounds;
> > 	const char filename[] = "large";
> > 	long *ret1;
> > 	long ret2;
> > 
> > 	if (argc != 4) {
> > 		printf("usage: thrash ANON_MB FILE_MB FILE_ROUNDS\n");
> > 		exit(0);
> > 	}
> > 	anon_mb = atoi(argv[1]);
> > 	file_mb = atoi(argv[2]);
> > 	file_rounds = atoi(argv[3]);
> > 
> > 	fallocate_file(filename, file_mb * MB);
> > 	printf("Allocate %ld MB anonymous pages\n", anon_mb);
> > 	ret1 = alloc_anon(anon_mb * MB);
> > 	printf("Access %ld MB file pages\n", file_mb);
> > 	ret2 = access_file(filename, file_mb * MB, file_rounds);
> > 	printf("Print result to prevent optimization: %ld\n",
> > 	       *ret1 + ret2);
> > 	return 0;
> > }
> > ---8<---
> > 
> > Running the test program on 2GB RAM VM with kernel 5.2.0-rc5, the
> > program fills ram with 2048 MB memory, access a 200 MB file for 10
> > times.  Without this patch, the file cache is dropped aggresively and
> > every access to the file is from disk.
> > 
> >   $ ./thrash 2048 200 10
> >   Allocate 2048 MB anonymous pages
> >   Access 200 MB file pages
> >   File access time, round 0: 2.489316 (sec)
> >   File access time, round 1: 2.581277 (sec)
> >   File access time, round 2: 2.487624 (sec)
> >   File access time, round 3: 2.449100 (sec)
> >   File access time, round 4: 2.420423 (sec)
> >   File access time, round 5: 2.343411 (sec)
> >   File access time, round 6: 2.454833 (sec)
> >   File access time, round 7: 2.483398 (sec)
> >   File access time, round 8: 2.572701 (sec)
> >   File access time, round 9: 2.493014 (sec)
> > 
> > With this patch, these file pages can be cached.
> > 
> >   $ ./thrash 2048 200 10
> >   Allocate 2048 MB anonymous pages
> >   Access 200 MB file pages
> >   File access time, round 0: 2.475189 (sec)
> >   File access time, round 1: 2.440777 (sec)
> >   File access time, round 2: 2.411671 (sec)
> >   File access time, round 3: 1.955267 (sec)
> >   File access time, round 4: 0.029924 (sec)
> >   File access time, round 5: 0.000808 (sec)
> >   File access time, round 6: 0.000771 (sec)
> >   File access time, round 7: 0.000746 (sec)
> >   File access time, round 8: 0.000738 (sec)
> >   File access time, round 9: 0.000747 (sec)
> 
> This is all good again.
> 
> > Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> 
> Please replace this line with the two Fixes: lines that I provided
> earlier in this thread.

Can't we have "Cc: <stable@vger.kernel.org> # 4.12+" so we have fix kernels which has
thrashing/workingset transition detection?

