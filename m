Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F32AC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC8D32184C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:18:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LP7CSZt6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC8D32184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBA986B0280; Mon, 27 May 2019 11:18:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E42F06B0281; Mon, 27 May 2019 11:18:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBF076B0282; Mon, 27 May 2019 11:18:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66F256B0280
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:18:58 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id r63so1640587lfe.7
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:18:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=N9QxOsCpG4vKL6hCt6g0lgf16oRDXncqDvwjRy+5AGhVG/grF2e2eW3u+gkg+S5WHn
         81zY5R7VQZuez/4Qyr5Uw9IUh8rueHsK0dVCQeBc+NVVm4AwZJmoLFaT5wL9wN+8B44E
         lGH6HczNgPwXbNa2veeP6AMRKrjuavB9izMvhLf4h6cs2PdjBbHa4wkKtIiNxuUSUv6v
         z0cJd0mgpLcXEny3K21hhulYJR0H3GZgYkmquxflnP6BOxWEQRb1BYwns4iPv8pWUvSz
         4FWvN+5gBwCJKQl4jly1D7cJwNcix4OaN8vVHZlCnPkj2qmJuDyk4fB/xb0JKmBQmZZU
         fyOw==
X-Gm-Message-State: APjAAAUUe7F2t8ziGDnfeQRx4z9Fnmgo47ORdjaZ0tFod8XIdVLLrBvt
	V2arorTLeHe2QkXHVE66AVVEyHsJTtwFxSIv4KYaIAWpTlZ2pmdbA+QAY5sC6XdRZZF72dXV9Dq
	ek1Rgw9uwzm7bOTh038f2st9IMloKuWuW01dCE7Sj+6rKAG+6XueO9ny4lIGXmQZFrA==
X-Received: by 2002:a2e:731a:: with SMTP id o26mr21635225ljc.105.1558970337752;
        Mon, 27 May 2019 08:18:57 -0700 (PDT)
X-Received: by 2002:a2e:731a:: with SMTP id o26mr21635165ljc.105.1558970336711;
        Mon, 27 May 2019 08:18:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558970336; cv=none;
        d=google.com; s=arc-20160816;
        b=r1rnJQBCLfDUEK/98Hwx1NPLQMrT3HmTySRdCXXu+1rbXBh0w1CaQiY3GhTTWN5XkP
         RPvFG2/owzEyqgboxnIbV4DKO1l99oik25jDiGVTJoEDZ0HFjTrnezmXdaba/St0tLhq
         FxnKIXjazR0B+M99iK9mSzgda4MOrYHnMUQCcgeNAWBaUpHX1lnQjT4p5PlDadUjIi8l
         navqkd7S4srV9Z8gC7XUg+sS1iabo5fnUJfAP1uvByeuxxZomtRwl2y1KXy+Avl3HlpZ
         aFgO2IzKKI5SzEGvuVLGgT/W4GiF+Ov+zVvoA9HR9OmAOJmc21zlBrJZLEHST7aY5Pvf
         iTIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=JHZsoOrOsD8G2JbxEkhH2U3rzt8+J2OIlWC0bjbvu0UhXiguEPXhKgWmTH+CgJqDKd
         3AvhkuUKXVCiXZMDcW5tQnnad4Cxv71f0uShi2q08HVz/UZNGmlOD9ymEV5Hrw0RU43n
         RTNwHh09HBemI8XzRrkG4qRfNIqpEabGoqTMgCSKKdNNfpsj0GHxTYPPW53lT8IU9xii
         kck4HQj+LilvZhdLTs/Kn9fyZ/0jIAFQfyiJ58Q17eVl+bCMAtFTXCssjYNDyxJpH0Iu
         SKdCT9RxemRq9BZl1Pcxy29gSE7uIT1pYwnL+1gKq+KzYHhyQUYfla8uA4ZH2KMCtmEN
         To9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LP7CSZt6;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor5537859lja.9.2019.05.27.08.18.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 08:18:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LP7CSZt6;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fnFIhfm6w+x6vlcZglDCubHYA2sqJDEBTXH+zDoT54E=;
        b=LP7CSZt6yjO7TpmhKCv3v+8DJMO2A46jdg+f6i14O7xUfZWn1qqLhb1pn7G/EOL3NF
         M9MRMawjq1deUOJNL9bVuotbqGM2QuXsCUIcp1lHT6GhYqpIpXQbdBhyaAFNr5vdMnLB
         a1uEgo51KSrkUe2rbBT12sksoTeRtWAbFZEKJi3N7N5JC5D5MKb325dYOfEk3KLhXD41
         yk+jQLdJG2hq/K1StoQtquSdmIcdtpl5zZiGP/EUk9NeQSg1ICoR9YHUizAYhfQjI1aT
         KbvtEuqIdohzLKfNtmGmC+/oeq6zQ2HP1YmLTYuZmRZ0zUrc69FwEBCRoOMIOU5UaPrW
         JXPQ==
X-Google-Smtp-Source: APXvYqzzoOQnxbgmmjIK0XSAM1M3uz8HqRTeMQNMnp77GiwQQsoprM514MzE0VvHchBzfv5uumvn9Q==
X-Received: by 2002:a2e:89d2:: with SMTP id c18mr6711906ljk.203.1558970336312;
        Mon, 27 May 2019 08:18:56 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h25sm2308701ljb.80.2019.05.27.08.18.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:18:55 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v4 1/4] mm/vmap: remove "node" argument
Date: Mon, 27 May 2019 17:18:40 +0200
Message-Id: <20190527151843.27416-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527151843.27416-1-urezki@gmail.com>
References: <20190527151843.27416-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove unused argument from the __alloc_vmap_area() function.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..ea1b65fac599 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -985,7 +985,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
  */
 static __always_inline unsigned long
 __alloc_vmap_area(unsigned long size, unsigned long align,
-	unsigned long vstart, unsigned long vend, int node)
+	unsigned long vstart, unsigned long vend)
 {
 	unsigned long nva_start_addr;
 	struct vmap_area *va;
@@ -1062,7 +1062,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * If an allocation fails, the "vend" address is
 	 * returned. Therefore trigger the overflow path.
 	 */
-	addr = __alloc_vmap_area(size, align, vstart, vend, node);
+	addr = __alloc_vmap_area(size, align, vstart, vend);
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

