Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEA1D620012
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:02:05 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o1BL21KO025520
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:02:01 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz9.hot.corp.google.com with ESMTP id o1BKxdTe032511
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:01:59 -0800
Received: by pzk37 with SMTP id 37so768373pzk.10
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:01:59 -0800 (PST)
Date: Thu, 11 Feb 2010 13:01:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <20100211150712.GA13140@emergent.ellipticsemi.com>
Message-ID: <alpine.DEB.2.00.1002111257300.1461@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com> <4B73833D.5070008@redhat.com> <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
 <20100211150712.GA13140@emergent.ellipticsemi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Bowler <nbowler@elliptictech.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Nick Bowler wrote:

> > As mentioned in the changelog, we've exported these minimum and maximum 
> > values via a kernel header file since at least 2006.  At what point do we 
> > assume they are going to be used and not hardcoded into applications?  
> > That was certainly the intention when making them user visible.
> 
> The thing is, even when the macros are used, their values are hardcoded
> into programs once the code is run through a compiler.  That's why it's
> called an ABI.
> 

Right, that's the second point that I listed: since the semantics of the 
tunable have radically changed from the bitshift to an actual unit 
(proportion of available memory), those applications need to change how 
they use oom_adj anyway.  The bitshift simply isn't extendable with any 
sane heuristic that is predictable or works with any reasonable amount of 
granularity, so this change seems inevitable in the long term.

We may be forced to abandon /proc/pid/oom_adj itself and introduce the 
tunable with a different name: oom_score_adj, for example, to make it 
clear that it's a different entity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
