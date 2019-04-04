Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B9F1C10F05
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36702217D4
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36702217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61D4B6B0006; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 576556B0007; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4161B6B000D; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB3876B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:15:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17so1032777edd.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:15:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=V9WCW+58a6z3WaR4DjrxqBV8pnkPxZyniSrFxwSIA8U=;
        b=IA8AxBxpnamkMIGMArsjvD7wHv/WcloSmT1aKrUGlu4bDmON2U6YOF2Xa59cohCODa
         EpnWLJb4jOljWGKHZ4pCRz11SjiQm0nap0dhWr8BeWfOm/iEs8DOiiJC/El7migot7eb
         lFlKTgctzkY84IlzgPAQ0ikbMbI2gu9mr7gi9iOBa5YozHgTiPB1rDHBKLHTCYH4nNCF
         RO8sKcqN7xSOsanJLJZaDsESuPJbtLsg5UMU33wA60HvChIyHIHrkBgcL3uSrbw9MSX5
         LCpf+3EKJlsSXEOZ/PW1oq3mrAl6e+/o515kcAMqVRG566Oa1sxYBl6ejkT4gHxAFH1B
         QwKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXKiQFkPnFYRw0k00Y71FTgHJisDBJdjGkWJsSwdk7N+Q0opGFd
	luG+s8MfkvskApRnJSgqlvtQNzml5l8iqDueQF9tUIJ9WvahU9Rd+vnkhZ72jLgmCiXNv61semP
	tk4jv3XgmJ5r5ok2Mf5IekzUsPhBYlYI75e3qIgNboq3zouxK94i/OicRQIiRPEq9Bg==
X-Received: by 2002:a17:906:883:: with SMTP id n3mr2829548eje.164.1554369345476;
        Thu, 04 Apr 2019 02:15:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxilG03vc8TYniCSzSApRokVZeRKmhOaFtRAUjaEi9bPmd97/WxyoWUN7gdYu9yDScdJTmc
X-Received: by 2002:a17:906:883:: with SMTP id n3mr2829485eje.164.1554369344124;
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554369344; cv=none;
        d=google.com; s=arc-20160816;
        b=eve1AdYv2JWNYxJxj+qUw8DUiz2r9dbrisn3N85Op6iHqeMEDNS6I9mV319vgspxYU
         LsCb6EMqyW/teLyAPqQe7SI180OUI4yagjebIZGbF3UawcsCwUSC160cdTHvxWBtX27m
         wQ3dMsv5+n7S6cDczWVnc/sTtSBefxza5pQ/8PGQXfuD25AqLvQ8nOvWgLH3owxz0ABg
         xUmw1o/thLIfJITkt2bS5IOi8bkasV3dye5Bofpa4g5r7cII4AHyZ6GSiMqnVANjt0mS
         FC4sBrGqYvXbAThha2zXnE87A3c24+pQA6CHJcOCsAqJTjhqVNLjcgSFYGkPg0DX9O/F
         ltcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=V9WCW+58a6z3WaR4DjrxqBV8pnkPxZyniSrFxwSIA8U=;
        b=Vfk77gbKnBCexSIJXeGw5ynrHqxhH4D9LZ5eJgjLWwe9Cu3gMhq150/7rBBAJu2V4w
         QAaPxh2PqnZhqlg8iD+0kV+ofksvtCBYgrq5YUdXgNt+xVBMNiiI/aRJ4CZTgcUQuwFM
         cSbkzFCUNDW96f+yox8QXCQmGVAg7rtBAGHfp4RTYHt5xmVNq59SZlrn1AT5Tofc0PvJ
         lmpsLaQUNNsar4Fgx5BpYJHIelK412/CC0OTpfnDMV66E3u/JCl+RRw2RRc2oMBKsYDZ
         Ye133N2ATtXtbxZqRPjpW6BSilZni0NHtEO2cNow93LLMPJ+yktEst7fNj+8onEjJe+8
         YCTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i19si5477892edr.185.2019.04.04.02.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4AA13ADC4;
	Thu,  4 Apr 2019 09:15:43 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/2] add static key for slub_debug
Date: Thu,  4 Apr 2019 11:15:29 +0200
Message-Id: <20190404091531.9815-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I looked a bit at SLUB debugging capabilities and first thing I noticed is
there's no static key guarding the runtime enablement as is common for similar
debugging functionalities, so here's a RFC to add it. Can be further improved
if there's interest.

It's true that in the alloc fast path the debugging check overhead is AFAICS
amortized by the per-cpu cache, i.e. when the allocation is from there, no
debugging functionality is performed. IMHO that's kinda a weakness, especially
for SLAB_STORE_USER, so I might also look at doing something about it, and then
the static key might be more critical for overhead reduction.

In the freeing fast path I quickly checked the stats and it seems that in
do_slab_free(), the "if (likely(page == c->page))" is not as likely as it
declares, as in the majority of cases, freeing doesn't happen on the object
that belongs to the page currently cached. So the advantage of a static key in
slow path __slab_free() should be more useful immediately.

Vlastimil Babka (2):
  mm, slub: introduce static key for slub_debug
  mm, slub: add missing kmem_cache_debug() checks

 mm/slub.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

-- 
2.21.0

