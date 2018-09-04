Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 127DF6B6F3F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:55:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u6-v6so2281702pgn.10
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:55:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a20-v6si20574837pgv.85.2018.09.04.12.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:55:04 -0700 (PDT)
Date: Tue, 4 Sep 2018 12:55:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/5] Extend and consolidate mmu_gather into new file
Message-Id: <20180904125501.642e1004825350aca476a653@linux-foundation.org>
In-Reply-To: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

On Tue,  4 Sep 2018 12:45:28 +0100 Will Deacon <will.deacon@arm.com> wrote:

> This series builds on the core changes I previously posted here:
> 
>   rfc:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/597821.html
>   v1:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/598919.html
> 
> The main changes are:
> 
>   * Move the mmu_gather bits out of memory.c and into their own file
>     (looped in the mm people for this)
> 
>   * Add a MAINTAINERS entry for the new file, and all tlb.h headers.
>     If any mm developers would like to be included here as well, please
>     just ask.
> 
> I'd like to queue these patches on their own branch in the arm64 git so
> that others can develop on top of them for the next merge window. Peter
> and Nick have both expressed an interest in that, and I already have a
> bunch of arm64 optimisations on top which I posted previously.

All looks good to me - please proceed that way.  Please also add me to
the MAINTAINERS record so I get more emails.
