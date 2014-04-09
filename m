Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3948F6B003C
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 19:43:23 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so9801918wiv.13
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 16:43:22 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id pc8si1293927wic.42.2014.04.09.16.35.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 16:36:08 -0700 (PDT)
Message-ID: <5345D912.7000606@zytor.com>
Date: Wed, 09 Apr 2014 16:34:42 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v2
References: <1396962570-18762-1-git-send-email-mgorman@suse.de> <53440A5D.6050301@zytor.com> <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com> <20140408164652.GL7292@suse.de> <20140408173031.GS10526@twins.programming.kicks-ass.net> <20140409062103.GA7294@gmail.com>
In-Reply-To: <20140409062103.GA7294@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2014 11:21 PM, Ingo Molnar wrote:
> 
> I think the real underlying objection was that PTE_NUMA was the last 
> leftover from AutoNUMA, and removing it would have made it not a 
> 'compromise' patch set between 'AutoNUMA' and 'sched/numa', but would 
> have made the sched/numa approach 'win' by and large.
> 
> The whole 'losing face' annoyance that plagues all of us (me 
> included).
> 
> I didn't feel it was important to the general logic of adding access 
> pattern aware NUMA placement logic to the scheduler, and I obviously 
> could not ignore the NAKs from various mm folks insisting on PTE_NUMA, 
> so I conceded that point and Mel built on that approach as well.
> 
> Nice it's being cleaned up, and I'm pretty happy about how NUMA 
> balancing ended up looking like.
> 

How painful would it be to get rid of _PAGE_NUMA entirely?  Page bits
are a highly precious commodity and saving one would be valuable.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
