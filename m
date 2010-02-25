Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E85DF6B007D
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 13:46:42 -0500 (EST)
Message-ID: <4B86C58B.5040906@cs.helsinki.fi>
Date: Thu, 25 Feb 2010 20:46:35 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002251232550.18861@router.home>
In-Reply-To: <alpine.DEB.2.00.1002251232550.18861@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Christoph Lameter wrote:
>> OK, can we get this issue resolved? The merge window is open and Christoph
>> seems to be unhappy with the whole patch queue. I'd hate this bug fix to miss
>> .34...
> 
> Merge window? These are bugs that have to be fixed independently from a
> merge window. The question is if this is the right approach or if there is
> other stuff still lurking because we are not yet seeing the full picture.

The first set of patches from Andi are almost one month old. If this 
issue progresses as swiftly as it has to this day, I foresee a rocky 
road for any of them getting merged to .34 through slab.git, that's all.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
