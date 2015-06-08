Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 05CE16B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 14:30:21 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so110491390pdb.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 11:30:20 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pw8si5314515pdb.85.2015.06.08.11.30.19
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 11:30:20 -0700 (PDT)
Message-ID: <5575DD33.3000400@intel.com>
Date: Mon, 08 Jun 2015 11:21:39 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com>
In-Reply-To: <20150608174551.GA27558@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 06/08/2015 10:45 AM, Ingo Molnar wrote:
> As per my measurements the __flush_tlb_single() primitive (which you use in patch
> #2) is very expensive on most Intel and AMD CPUs. It barely makes sense for a 2
> pages and gets exponentially worse. It's probably done in microcode and its 
> performance is horrible.

I discussed this a bit in commit a5102476a2.  I'd be curious what
numbers you came up with.

But, don't we have to take in to account the cost of refilling the TLB
in addition to the cost of emptying it?  The TLB size is historically
increasing on a per-core basis, so isn't this refill cost only going to
get worse?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
