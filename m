Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 751226B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:29:28 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so72475979pgi.2
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 21:29:28 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b189si20408110pgc.242.2017.01.15.21.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 21:29:27 -0800 (PST)
From: Dave Hansen <dave.hansen@intel.com>
Subject: [LSF/MM TOPIC/ATTEND] Memory Types
Message-ID: <9a0ae921-34df-db23-a25e-022f189608f4@intel.com>
Date: Sun, 15 Jan 2017 21:29:26 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>

Historically, computers have sped up memory accesses by either adding
cache (or cache layers), or by moving to faster memory technologies
(like the DDR3 to DDR4 transition).  Today we are seeing new types of
memory being exposed not as caches, but as RAM [1].

I'd like to discuss how the NUMA APIs are being reused to manage not
just the physical locality of memory, but the various types.  I'd also
like to discuss the parts of the NUMA API that are a bit lacking to
manage these types, like the inability to have fallback lists based on
memory type instead of location.

I believe this needs to be a distinct discussion from Jerome's HMM
topic.  All of the cases we care about are cache-coherent and can be
treated as "normal" RAM by the VM.  The HMM model is for on-device
memory and is largely managed outside the core VM.

I'd like to attend to discuss any of the performance and swap topics, as
well as the ZONE_DEVICE and HMM discussions.

1.
https://software.intel.com/en-us/articles/mcdram-high-bandwidth-memory-on-knights-landing-analysis-methods-tools

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
