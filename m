Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0F0C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F1021726
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:03:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UQTCOigF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F1021726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2328A8E0003; Thu, 27 Jun 2019 00:03:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E4208E0002; Thu, 27 Jun 2019 00:03:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AB288E0003; Thu, 27 Jun 2019 00:03:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C457B8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 00:03:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so683574pfn.15
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 21:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VrVCHvqS+161HTIY8XI7UkOd1ZKM1qjN7YCrNuIuxOI=;
        b=lr9W2opJymc7YPsW3Q4RpOtYnB+axePWbfOluaL4jpXCVFNlohCLn5Sh21TfYDk9+Q
         aSpYAqqitNz4x1ydmEa3xgmEySYpBUZAfrfczY/92e66AfCPxEo6p4+ORZidgXC2k6Bs
         EE6cgQ5p2mOXEocD2HR9+gNP7qsy+MvaU+qro/EYNp11NSc5Yru5e8lBDHU1Iii8xoZT
         p7msI62pG/GaIwX8tu9CgL+wkLNTO4q5CJxzNSEH47RqB9EmTU1NWKQximvgkKRdeoNQ
         XN/dh4ODocGtNWGm1XXCvIfAHScAW9EIriXAOhWXVHmXnrB5NO94AJ7RHbSH3FNkHydl
         XwcQ==
X-Gm-Message-State: APjAAAUQI+eagfJ9TpFSg5Fd6fIY54mYmAJRLyysvCKPu7al/V/PTSsv
	P5ep+aSvt3s6r6mUwWOUU+duogrHJpTYl8yjKzyAo6UpkZVr1rvvMQbiZIdfX+IfFH4GjX2NZrP
	41BUy6MBbzQb7el0Uf/XprNEw3xlCUZkGsjsXgCaBjBOUtji5ZtrvVypG49UkOGXDwA==
X-Received: by 2002:a63:6981:: with SMTP id e123mr1610151pgc.136.1561608201236;
        Wed, 26 Jun 2019 21:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjB7lYkV5CjGdwGb2ru3SRfory/Q+T9NUO0kNpI3mjabQP9SLxVy9g1b0aNscsVCU/vszJ
X-Received: by 2002:a63:6981:: with SMTP id e123mr1610054pgc.136.1561608199967;
        Wed, 26 Jun 2019 21:03:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561608199; cv=none;
        d=google.com; s=arc-20160816;
        b=bhSKx/egLWZH0nWMIqGKEehlrOCVZ25VqCBXaTkpdyK3Pf8pqrR5TJxJ7/9tQWo0MJ
         SIRze4HYu3AsG1rvDV+6Tx1/6YQR7rtIRG7yQPnc/sr4dqNGSVq4AhvkCNdDQ+PGNiZ7
         58Ug13GNr4hzsRzFHnI6CPn9em/k+BFDMV05v4C/XB6gjaVFGvyjKd284xlaGx7Va3ko
         +cW5z4fcTyNVa+YEfVjTKoto92YQkog98IYBewvXZuhVKS4nwgORofZNocGSVReedJkC
         w/ZaLOWwntosya3SiT4wGxY+j8+/CAyQwflv6pq1T6ABmR2/QaEvg+8RzuQb5rmAA98t
         EpDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VrVCHvqS+161HTIY8XI7UkOd1ZKM1qjN7YCrNuIuxOI=;
        b=Q/23mmSoE34COS7bMUfTh70LQ/hqcw1625nuJmaBPwsSoFU9eZGD+mS/EUSKdk12Qf
         4skKps38q1IltK9S9AtCXPNNTNS/5M6mATzVCzA94dAyf4U71q4RC3tQ+JBwSlzflqu5
         YYM9K6otSep/z/cyQp7/hV7aKnK6Q/8+pCtZlJwhNuwrZ9TxLpf/osr6sY3ZwqwItVca
         tf3EUGXZhxCPn0qKrW0yr99ffIk/TyyObeYQDUEbYwMENymy+xmas8zJox62QZTccxFw
         7uJaA53ECmAOeNQtoNwFjxjKkf90DamsajYPQqcCPAQEImnfoayOFFTONI92HZ/MHlVD
         yeRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UQTCOigF;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x20si1137023pll.105.2019.06.26.21.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 21:03:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UQTCOigF;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 34EDB20665;
	Thu, 27 Jun 2019 04:03:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561608199;
	bh=SlTXh2p/gZLvTtduY3oa5W16xSgTr4O6Sb7YsAg67yw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=UQTCOigFlal+jLNVCEMxU9SMZjBz7DxdN6SUdRf48bXzHgUx/6a1Y1Mm+V32b2iXN
	 N5j/viwFx/q67djfUKPLE0LSrUFqbhsITxsm/so7UyTGGcz4jZckZPZfoGPNtsnGHU
	 EAL2yHl30SPElMv2NsmtSzpxYVbTeLs+9U5rpLqw=
Date: Wed, 26 Jun 2019 21:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>,
 Sonny Rao <sonnyrao@chromium.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-Id: <20190626210318.af48d796f461f704a535a88d@linux-foundation.org>
In-Reply-To: <20190619080835.GA68312@google.com>
References: <20190619080835.GA68312@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Could we please get some review of this one?  Johannes, it supposedly
fixes your patch?

I added cc:stable to this.  Agreeable?

From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: mm: vmscan: fix not scanning anonymous pages when detecting file refaults

When file refaults are detected and there are many inactive file pages,
the system never reclaim anonymous pages, the file pages are dropped
aggressively when there are still a lot of cold anonymous pages and system
thrashes.  This issue impacts the performance of applications with large
executable, e.g.  chrome.

When file refaults are detected.  inactive_list_is_low() may return
different values depends on the actual_reclaim parameter, the following 2
conditions could be satisfied at the same time.

1) inactive_list_is_low() returns false in get_scan_count() to trigger
   scanning file lists only.
2) inactive_list_is_low() returns true in shrink_list() to allow
   scanning active file list.

In that case vmscan would only scan file lists, and as active file list is
also scanned, inactive_list_is_low() may keep returning false in
get_scan_count() until file cache is very low.

Before 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache
workingset transition"), inactive_list_is_low() never returns different
value in get_scan_count() and shrink_list() in one shrink_node_memcg()
run.  The original design should be that when inactive_list_is_low()
returns false for file lists, vmscan only scan inactive file list.  As
only inactive file list is scanned, inactive_list_is_low() would soon
return true.

This patch makes the return value of inactive_list_is_low() independent of
actual_reclaim.

The problem can be reproduced by the following test program.

---8<---
void fallocate_file(const char *filename, off_t size)
{
	struct stat st;
	int fd;

	if (!stat(filename, &st) && st.st_size >= size)
		return;

	fd = open(filename, O_WRONLY | O_CREAT, 0600);
	if (fd < 0) {
		perror("create file");
		exit(1);
	}
	if (posix_fallocate(fd, 0, size)) {
		perror("fallocate");
		exit(1);
	}
	close(fd);
}

long *alloc_anon(long size)
{
	long *start = malloc(size);
	memset(start, 1, size);
	return start;
}

long access_file(const char *filename, long size, long rounds)
{
	int fd, i;
	volatile char *start1, *end1, *start2;
	const int page_size = getpagesize();
	long sum = 0;

	fd = open(filename, O_RDONLY);
	if (fd == -1) {
		perror("open");
		exit(1);
	}

	/*
	 * Some applications, e.g. chrome, use a lot of executable file
	 * pages, map some of the pages with PROT_EXEC flag to simulate
	 * the behavior.
	 */
	start1 = mmap(NULL, size / 2, PROT_READ | PROT_EXEC, MAP_SHARED,
		      fd, 0);
	if (start1 == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	end1 = start1 + size / 2;

	start2 = mmap(NULL, size / 2, PROT_READ, MAP_SHARED, fd, size / 2);
	if (start2 == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}

	for (i = 0; i < rounds; ++i) {
		struct timeval before, after;
		volatile char *ptr1 = start1, *ptr2 = start2;
		gettimeofday(&before, NULL);
		for (; ptr1 < end1; ptr1 += page_size, ptr2 += page_size)
			sum += *ptr1 + *ptr2;
		gettimeofday(&after, NULL);
		printf("File access time, round %d: %f (sec)
", i,
		       (after.tv_sec - before.tv_sec) +
		       (after.tv_usec - before.tv_usec) / 1000000.0);
	}
	return sum;
}

int main(int argc, char *argv[])
{
	const long MB = 1024 * 1024;
	long anon_mb, file_mb, file_rounds;
	const char filename[] = "large";
	long *ret1;
	long ret2;

	if (argc != 4) {
		printf("usage: thrash ANON_MB FILE_MB FILE_ROUNDS
");
		exit(0);
	}
	anon_mb = atoi(argv[1]);
	file_mb = atoi(argv[2]);
	file_rounds = atoi(argv[3]);

	fallocate_file(filename, file_mb * MB);
	printf("Allocate %ld MB anonymous pages
", anon_mb);
	ret1 = alloc_anon(anon_mb * MB);
	printf("Access %ld MB file pages
", file_mb);
	ret2 = access_file(filename, file_mb * MB, file_rounds);
	printf("Print result to prevent optimization: %ld
",
	       *ret1 + ret2);
	return 0;
}
---8<---

Running the test program on 2GB RAM VM with kernel 5.2.0-rc5, the program
fills ram with 2048 MB memory, access a 200 MB file for 10 times.  Without
this patch, the file cache is dropped aggresively and every access to the
file is from disk.

  $ ./thrash 2048 200 10
  Allocate 2048 MB anonymous pages
  Access 200 MB file pages
  File access time, round 0: 2.489316 (sec)
  File access time, round 1: 2.581277 (sec)
  File access time, round 2: 2.487624 (sec)
  File access time, round 3: 2.449100 (sec)
  File access time, round 4: 2.420423 (sec)
  File access time, round 5: 2.343411 (sec)
  File access time, round 6: 2.454833 (sec)
  File access time, round 7: 2.483398 (sec)
  File access time, round 8: 2.572701 (sec)
  File access time, round 9: 2.493014 (sec)

With this patch, these file pages can be cached.

  $ ./thrash 2048 200 10
  Allocate 2048 MB anonymous pages
  Access 200 MB file pages
  File access time, round 0: 2.475189 (sec)
  File access time, round 1: 2.440777 (sec)
  File access time, round 2: 2.411671 (sec)
  File access time, round 3: 1.955267 (sec)
  File access time, round 4: 0.029924 (sec)
  File access time, round 5: 0.000808 (sec)
  File access time, round 6: 0.000771 (sec)
  File access time, round 7: 0.000746 (sec)
  File access time, round 8: 0.000738 (sec)
  File access time, round 9: 0.000747 (sec)

Link: http://lkml.kernel.org/r/20190619080835.GA68312@google.com
Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Sonny Rao <sonnyrao@chromium.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/vmscan.c~mm-vmscan-fix-not-scanning-anonymous-pages-when-detecting-file-refaults
+++ a/mm/vmscan.c
@@ -2151,7 +2151,7 @@ static bool inactive_list_is_low(struct
 	 * rid of the stale workingset quickly.
 	 */
 	refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
-	if (file && actual_reclaim && lruvec->refaults != refaults) {
+	if (file && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
 		gb = (inactive + active) >> (30 - PAGE_SHIFT);
_

