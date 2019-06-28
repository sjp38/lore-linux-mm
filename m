Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0FD7C46478
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6174A214AF
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:51:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cv6URamx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6174A214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DE06B0003; Fri, 28 Jun 2019 02:51:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B10018E0003; Fri, 28 Jun 2019 02:51:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FD8C8E0002; Fri, 28 Jun 2019 02:51:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 665686B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 02:51:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b24so2944248plz.20
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 23:51:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mCstpKpvgbBC+V+ZGiWFlCxOPjghNzZbXr1kJOJkGEc=;
        b=U0YieTUV5glkyeIPUY1yeZqbWBJvnHD674x+awqf3YyP62nrw0D377jk3hFk005D+l
         3q6nLiMpC4LIG9TTmIvwsDfwh3EhBa0ndeNgDBCFsDR8fDbNox4jIGViOXY4D3C+W3Rh
         GxRB/HzAVq4lBc91h3TnD6aDX6VMx8KTfiwGX/YBWJXnVmmRDeEAj9lNHAnHmRIbSTAL
         lGZ4N03pOVWMTw01/GisTGLwNZVDYC49kS+PWVZrGocLgTa/i+NesgI1qpkGERKzvgxF
         mw06YpbL8xlCJVODufqUSeST6PdGrpOfsiE/bEflrsLYVLUQmHyRc1G/gVRzOVTGt1HR
         BA4Q==
X-Gm-Message-State: APjAAAWjEawmpPGNpEbhKQftEmD5piIlxTz+qsFrVyGTMTrv6T8mr3mq
	IjyPpoXmsEfy7vBxuQ6h4EBB+L1md5ZnDcmJtSI6qqDSiD3L5+5jXp2ONIXV72/h+Uesf2imkIf
	sj7X2b/gO14NgZVM6irDYf/TRaq8O9TFVhcOpb0dxixZKI3aTLHicQFGYLX5KtJE=
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr9748201plr.198.1561704705943;
        Thu, 27 Jun 2019 23:51:45 -0700 (PDT)
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr9748122plr.198.1561704704797;
        Thu, 27 Jun 2019 23:51:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561704704; cv=none;
        d=google.com; s=arc-20160816;
        b=qBOCoGuDcAFk1WuvfBQRsXxj8gw+rTmamG41I7fwSjmIaQF0yJZzv9g/u7mGrgrps7
         1o+YTnbZbE2cIc1DiRs8ddddr+On/QIP4nVSx4scOIyVDEtuuAAZyP8zUY3scBWTnW7K
         I18nzJFwdVTg3/uZVOLuisPytS4EVIBhmWTjCHUNNtPe5VP0/k/wTOXmjaBAvMGshQnF
         5RmyRUFZwkAjoni+VZiXCIc253Wp2RjSPQCzbHOip+yJlv37yEDOOV3/ACa3BmFmKlPk
         p7Ql++X2JDOGVZxtla+lFHpjR5C5rm731Kkc75Rpx/cYdsK7uyjsAgx0xk2sgWUo6vWY
         EI6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=mCstpKpvgbBC+V+ZGiWFlCxOPjghNzZbXr1kJOJkGEc=;
        b=SSCMJaJBKTMylE9E7qm1BTpXGQ1EmBqe/hsF1ZBwM8O2TxRJCm9QeaWBNht7MJB+yx
         lHUI3+ncIC5+6EXmI7CB0X6mTWJLsAeq57ETQsqhXuwV42tdOEJVMqFqc7E0FJabXmoE
         65J4LrcPyxEbZ5pCk7whPu9QwDy4UDXzIhyeMORF7nK4TfdLn4RvZZHIYScAxObTgca1
         JP/dUTtc2ipmbYg0Uv3p7NurQaoj+Sqq3i7PcaaXB0TVmqHe69DonlSAqBPuqAER4eCR
         E2odDLUS+sRjcoTi4fFkXWAre+7kaCzbyVyUZRNmBZXx82eplVy+OG4xecQJcZP3eim+
         SSew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cv6URamx;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9sor1481464plv.3.2019.06.27.23.51.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 23:51:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cv6URamx;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mCstpKpvgbBC+V+ZGiWFlCxOPjghNzZbXr1kJOJkGEc=;
        b=Cv6URamx2iez5Bj7TuIlhxGqHMOHEygYhuPAvLwOBofBDUglWIMw6QdOGPE73NQ6+i
         jav6fRvR0NxwWAYc3M4mcV4KkwniIE0+DN9BgNIy7ng1I8LL3V9c861VT0Mkbmx7mC9N
         XGLVsuuq500ozM+G8Ui+mQjISaOIxPaU3cOkGDCtd9Vyy9OgRtlfuNKeA+I7aE3nz2Hr
         taBSqBi3qcGKuPWxaNJoWNCupfRrMuMfUeLAzTyq3HwfoaGB9JSEheS21EIa6ByWe/jg
         oQ3malVO0XGQYEpnPI6g+Au35JqstM4w6ueSgeJmsm2dmTDleG4RBR1U+TdoyM29PAjK
         AFXg==
X-Google-Smtp-Source: APXvYqx0UNr92nbIQgrbFzeisVKRoLX5W8EvyZ4FlCsQmFV+ndqxBqkjfrAhnW2TJAC39KbTxs9vPA==
X-Received: by 2002:a17:902:542:: with SMTP id 60mr9722394plf.68.1561704703972;
        Thu, 27 Jun 2019 23:51:43 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a21sm1303140pfi.27.2019.06.27.23.51.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 23:51:42 -0700 (PDT)
Date: Fri, 28 Jun 2019 15:51:38 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628065138.GA251482@google.com>
References: <20190619080835.GA68312@google.com>
 <20190627184123.GA11181@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627184123.GA11181@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

On Thu, Jun 27, 2019 at 02:41:23PM -0400, Johannes Weiner wrote:
> On Wed, Jun 19, 2019 at 04:08:35PM +0800, Kuo-Hsin Yang wrote:
> > When file refaults are detected and there are many inactive file pages,
> > the system never reclaim anonymous pages, the file pages are dropped
> > aggressively when there are still a lot of cold anonymous pages and
> > system thrashes. This issue impacts the performance of applications with
> > large executable, e.g. chrome.
> > 
> > When file refaults are detected. inactive_list_is_low() may return
> > different values depends on the actual_reclaim parameter, the following
> > 2 conditions could be satisfied at the same time.
> > 
> > 1) inactive_list_is_low() returns false in get_scan_count() to trigger
> >    scanning file lists only.
> > 2) inactive_list_is_low() returns true in shrink_list() to allow
> >    scanning active file list.
> > 
> > In that case vmscan would only scan file lists, and as active file list
> > is also scanned, inactive_list_is_low() may keep returning false in
> > get_scan_count() until file cache is very low.
> > 
> > Before commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in
> > cache workingset transition"), inactive_list_is_low() never returns
> > different value in get_scan_count() and shrink_list() in one
> > shrink_node_memcg() run. The original design should be that when
> > inactive_list_is_low() returns false for file lists, vmscan only scan
> > inactive file list. As only inactive file list is scanned,
> > inactive_list_is_low() would soon return true.
> > 
> > This patch makes the return value of inactive_list_is_low() independent
> > of actual_reclaim.
> > 
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
> > times. Without this patch, the file cache is dropped aggresively and
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
> > 
> > Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Your change makes sense - we should indeed not force cache trimming
> only while the page cache is experiencing refaults.
> 
> I can't say I fully understand the changelog, though. The problem of

I guess the point of the patch is "actual_reclaim" paramter made divergency
to balance file vs. anon LRU in get_scan_count. Thus, it ends up scanning
file LRU active/inactive list at file thrashing state.

So, Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
would make sense to me since it introduces the parameter.

> forcing cache trimming while there is enough page cache is older than
> the commit you refer to. It could be argued that this commit is
> incomplete - it could have added refault detection not just to
> inactive:active file balancing, but also the file:anon balancing; but
> it didn't *cause* this problem.
> 
> Shouldn't this be
> 
> Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
> Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")

That would affect, too but it would be trouble to have stable backport
since we don't have refault machinery in there.

