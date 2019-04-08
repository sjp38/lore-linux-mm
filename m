Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31599C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D128620880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:59:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IaVs/v49"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D128620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68F356B0007; Mon,  8 Apr 2019 15:59:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 616736B0008; Mon,  8 Apr 2019 15:59:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DE7C6B000A; Mon,  8 Apr 2019 15:59:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDF36B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:59:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b34so10650678pld.17
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:59:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=RSStTgCMJwvCqECwFlnDBhxtF8I569p9e6PuxiQP1oM=;
        b=Ml/qo4sD5b0KIGRgn7UKSkgiEj2t2PUCmjTPx00zC8GblbVym/Pgl9TGfASeI/hTML
         2YdmTiAf71Jst8uprc545REPyzGWLzetcYuEGE9TBmw9DPWUH9Y5OFN+n4OKGKxmj0L5
         J0sdzllhxYnrFuLU0ECE8wY5ZnAOWQSusQo5etUrSqxSz7Cyxg2AzS2GcGMjzu9VTI8U
         GJIWfZKT73IIvDS2m499Er3kVMotkF/mX6FEcQaCmpJUoq91rvlTPFegi+YRmaOcqZaC
         arRn/9xIgC2tdVsvkVtdstyiqhx8Cd2IKbZabDqy2i6gAleyp91rYdOrX9DrYHIYuFZY
         X+5Q==
X-Gm-Message-State: APjAAAV+6zd9agQ7O594/6w6ZKY+fXGhRJV4nsoLvrdTm9mG5hWISmIx
	oe9u4jKIGNLnInlwXZKIk3kXrgm1wGAUO8eNn4XRiyXi3ZQjIGcxv/TpSzVFe7JB41LGI7A+bKa
	ALeIlBPacMWbVyL6PpzyHBr3STQ8//3Va5wedzo+WYEgwzPKwqtnggQq3BXQyyh283Q==
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr31047792pgt.168.1554753576666;
        Mon, 08 Apr 2019 12:59:36 -0700 (PDT)
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr31047751pgt.168.1554753575947;
        Mon, 08 Apr 2019 12:59:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554753575; cv=none;
        d=google.com; s=arc-20160816;
        b=0zd7AI80mBVirqJmg4j6dfvmqAAB9/hxji/hvp5nF963UJuzRKprw6zx+tuGkiFBE5
         FS72iwXWi+Jamo874UuMQOSRKn5pZpnr/t4ORwkb7uxfVkwBToEF+M4fA5Pi2ePDkiM6
         Gv4iDN9EvyYkvfwrDsu77rFwHYxsTDPLMErouVzGqDEhmPz9aNOWH5GwzLleWjA1oTTB
         nf6893jictrH8aFOKTHRbiY9ypmeDO3iQsINCb7cnuzDPC8+qBQl2cJ1l12QsHm3iYtE
         nsD1c4yXUezs+7LMvit8AWVFDML1Hrkf7RJl6IFqvdDLWh1NqFuooZ+ni/UjdjXmTyId
         1Vcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=RSStTgCMJwvCqECwFlnDBhxtF8I569p9e6PuxiQP1oM=;
        b=ko0fPHd8zVftg/LTbnpaOXXaaZgf/mx5a4U2Jvz+l9CTOak0mLzcxSrP8MSc7Kdnva
         4qX4sxjcyC1H+f99TFtb12yVrEyNw3dTU6RFQFMFaUtgld/0HjiTzZfYcVVKtG+oCK6I
         /9ihdw020vqa8ldZ1diqyQdRDQPtT33Q7yi+vxID5iTrJsVGzQZPrtPWlLysWqjwZ/F7
         jsjSIo8tPeX4NTBj/lhgZz81dmGDpGLyGhtC7+QGcf4OOpcwdeTbWzpX+7J62OsRtdCV
         xugM6eJ8LC1BiJBcpOgnNteVWo27dc9Ra3KEnLn/y2TdlpKjHJ2PcQ5g2n5p8q2ey0sD
         G23Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="IaVs/v49";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a73sor12823628pge.24.2019.04.08.12.59.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 12:59:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="IaVs/v49";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=RSStTgCMJwvCqECwFlnDBhxtF8I569p9e6PuxiQP1oM=;
        b=IaVs/v49W9F4RB08+llfR3LzCZzsnZdb9KI01bTePyyBQrFAkbpQgsu5FDJDr4nZ/m
         YA6tTLHgZuvBGyWo/ywVHmrLflS/IVvDlnqE04G9JZQ6H5X7Xn+Co+j/3YHc5dB4U07s
         hbx3CzJxJZajypW7gQfNirQWke+RqbuAZFyNwtCXf8XQqi4eOU+ydwDNX5yNZ0pO+7N5
         GmmBYlJvxnFG59cHiMFKUAf6KwMbkN173hB3GNxcqSoZtnqFuDaGFZTSblrnWbNsLT/W
         kMw1dwylomWuocQ2hW4ZhH1yohtb86UkZvXeLQtvEK96NHD+YFp2Wh06ZkCcU3MSMPt2
         H3pQ==
X-Google-Smtp-Source: APXvYqzfmpdTWEuDsxZC2Dtn2LoyYq29oaMJey0FNJtIvQ4jPQhwzXYeWniqDVNGM3maON9MarpjjA==
X-Received: by 2002:a65:5383:: with SMTP id x3mr12785290pgq.60.1554753574808;
        Mon, 08 Apr 2019 12:59:34 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id j16sm41059643pfi.58.2019.04.08.12.59.33
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 12:59:33 -0700 (PDT)
Date: Mon, 8 Apr 2019 12:59:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH 3/4] mm: swapoff: take notice of completion sooner
In-Reply-To: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904081258200.1523@eggly.anvils>
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The old try_to_unuse() implementation was driven by find_next_to_unuse(),
which terminated as soon as all the swap had been freed.  Add inuse_pages
checks now (alongside signal_pending()) to stop scanning mms and swap_map
once finished.  The same ought to be done in shmem_unuse() too, but never
was before, and needs a different interface: so leave it as is for now.

Fixes: b56a2d8af914 ("mm: rid swapoff of quadratic complexity")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

--- 5.1-rc4/mm/swapfile.c	2019-04-07 19:15:01.269054187 -0700
+++ linux/mm/swapfile.c	2019-04-07 19:17:13.291957539 -0700
@@ -2051,11 +2051,9 @@ retry:
 
 	spin_lock(&mmlist_lock);
 	p = &init_mm.mmlist;
-	while ((p = p->next) != &init_mm.mmlist) {
-		if (signal_pending(current)) {
-			retval = -EINTR;
-			break;
-		}
+	while (si->inuse_pages &&
+	       !signal_pending(current) &&
+	       (p = p->next) != &init_mm.mmlist) {
 
 		mm = list_entry(p, struct mm_struct, mmlist);
 		if (!mmget_not_zero(mm))
@@ -2082,7 +2080,9 @@ retry:
 	mmput(prev_mm);
 
 	i = 0;
-	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
+	while (si->inuse_pages &&
+	       !signal_pending(current) &&
+	       (i = find_next_to_unuse(si, i, frontswap)) != 0) {
 
 		entry = swp_entry(type, i);
 		page = find_get_page(swap_address_space(entry), i);
@@ -2123,8 +2123,11 @@ retry:
 	 * separate lists, and wait for those lists to be emptied; but it's
 	 * easier and more robust (though cpu-intensive) just to keep retrying.
 	 */
-	if (si->inuse_pages)
-		goto retry;
+	if (si->inuse_pages) {
+		if (!signal_pending(current))
+			goto retry;
+		retval = -EINTR;
+	}
 out:
 	return (retval == FRONTSWAP_PAGES_UNUSED) ? 0 : retval;
 }

