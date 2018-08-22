Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7995D6B2518
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:46:00 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p5-v6so1368128pfh.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:46:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d1-v6si1938162pla.103.2018.08.22.08.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 08:45:59 -0700 (PDT)
Message-ID: <20180822153012.173508681@infradead.org>
Date: Wed, 22 Aug 2018 17:30:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 0/4] x86: TLB invalidate fixes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Here are a number of patches that fix a x86 TLB invalidation issue reported by
Jann and some related things that came up while sorting this out.

Please consider.
