Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C10E7C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 807752186A
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="WcGMRhKH";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="WcGMRhKH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 807752186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10C5F6B0008; Fri, 30 Aug 2019 08:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BE5C6B000A; Fri, 30 Aug 2019 08:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EED606B000C; Fri, 30 Aug 2019 08:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id C84E16B0008
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:44:05 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7AD371F85A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:44:05 +0000 (UTC)
X-FDA: 75879061650.08.song60_68e387b2693e
X-HE-Tag: song60_68e387b2693e
X-Filterd-Recvd-Size: 5543
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:44:04 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id D7D90602F2; Fri, 30 Aug 2019 12:44:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567169043;
	bh=bTajOsLB1qZ5mlLoBtttO/RiZmPYso1abxbVOc2sF1k=;
	h=From:To:Cc:Subject:Date:From;
	b=WcGMRhKH7dqg/RNz2k9+tZ6Lkx/TEVGnSUEFrN8eFB7irkhE18hV2LRPTDJKgM7Qn
	 MN0tcPgRaF7kKK6owPJZt1vkR9aej15j0KkIzQw1+ml5seMSQMgeDf9+CYIuKjDOpc
	 Rco8K/GuKAREebJKMqPOd9OzMfpyTcBFtQYzY0p0=
Received: from vinmenon-linux.qualcomm.com (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id E7D5E602F2;
	Fri, 30 Aug 2019 12:44:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567169043;
	bh=bTajOsLB1qZ5mlLoBtttO/RiZmPYso1abxbVOc2sF1k=;
	h=From:To:Cc:Subject:Date:From;
	b=WcGMRhKH7dqg/RNz2k9+tZ6Lkx/TEVGnSUEFrN8eFB7irkhE18hV2LRPTDJKgM7Qn
	 MN0tcPgRaF7kKK6owPJZt1vkR9aej15j0KkIzQw1+ml5seMSQMgeDf9+CYIuKjDOpc
	 Rco8K/GuKAREebJKMqPOd9OzMfpyTcBFtQYzY0p0=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org E7D5E602F2
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
From: Vinayak Menon <vinmenon@codeaurora.org>
To: minchan@kernel.org,
	linux-mm@kvack.org
Cc: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: fix the race between swapin_readahead and SWP_SYNCHRONOUS_IO path
Date: Fri, 30 Aug 2019 18:13:31 +0530
Message-Id: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The following race is observed due to which a processes faulting
on a swap entry, finds the page neither in swapcache nor swap. This
causes zram to give a zero filled page that gets mapped to the
process, resulting in a user space crash later.

Consider parent and child processes Pa and Pb sharing the same swap
slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
Virtual address 'VA' of Pa and Pb points to the shared swap entry.

Pa                                       Pb

fault on VA                              fault on VA
do_swap_page                             do_swap_page
lookup_swap_cache fails                  lookup_swap_cache fails
                                         Pb scheduled out
swapin_readahead (deletes zram entry)
swap_free (makes swap_count 1)
                                         Pb scheduled in
                                         swap_readpage (swap_count == 1)
                                         Takes SWP_SYNCHRONOUS_IO path
                                         zram enrty absent
                                         zram gives a zero filled page

Fix this by reading the swap_count before lookup_swap_cache, which conforms
with the order in which page is added to swap cache and swap count is
decremented in do_swap_page. In the race case above, this will let Pb take
the readahead path and thus pick the proper page from swapcache.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/memory.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e0c232f..22643aa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2744,6 +2744,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	struct page *page = NULL, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
+	struct swap_info_struct *si;
+	bool skip_swapcache = false;
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
@@ -2771,15 +2773,24 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
+
+	/*
+	 * lookup_swap_cache below can fail and before the SWP_SYNCHRONOUS_IO
+	 * check is made, another process can populate the swapcache, delete
+	 * the swap entry and decrement the swap count. So decide on taking
+	 * the SWP_SYNCHRONOUS_IO path before the lookup. In the event of the
+	 * race described, the victim process will find a swap_count > 1
+	 * and can then take the readahead path instead of SWP_SYNCHRONOUS_IO.
+	 */
+	si = swp_swap_info(entry);
+	if (si->flags & SWP_SYNCHRONOUS_IO && __swap_count(entry) == 1)
+		skip_swapcache = true;
+
 	page = lookup_swap_cache(entry, vma, vmf->address);
 	swapcache = page;
 
 	if (!page) {
-		struct swap_info_struct *si = swp_swap_info(entry);
-
-		if (si->flags & SWP_SYNCHRONOUS_IO &&
-				__swap_count(entry) == 1) {
-			/* skip swapcache */
+		if (skip_swapcache) {
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 							vmf->address);
 			if (page) {
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation


