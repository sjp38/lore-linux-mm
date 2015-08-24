Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 422F06B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:50:23 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so63438673wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:50:22 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id q7si20018725wiz.8.2015.08.24.00.50.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 00:50:22 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so63636904wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:50:21 -0700 (PDT)
Date: Mon, 24 Aug 2015 09:50:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/3 v5] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150824075018.GB20106@gmail.com>
References: <20150823081750.GA28349@gmail.com>
 <20150824010403.27903.qmail@ns.horizon.com>
 <20150824073422.GC13082@gmail.com>
 <20150824074714.GA20106@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824074714.GA20106@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* Ingo Molnar <mingo@kernel.org> wrote:

> One more detail: I just realized that with the read barriers, the READ_ONCE() 
> accesses are not needed anymore - the barriers and the control dependencies are 
> enough.
> 
> This will further simplify the code.

I.e. something like the updated patch below. (We still need the WRITE_ONCE() for 
vmap_info_gen update.)

Thanks,

	Ingo

========================>
