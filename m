Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38E696B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 09:31:21 -0500 (EST)
Date: Mon, 22 Feb 2010 15:31:11 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-ID: <20100222143111.GA15778@basil.fritz.box>
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <4B826227.9010101@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B826227.9010101@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 22, 2010 at 12:53:27PM +0200, Pekka Enberg wrote:
> Andi Kleen kirjoitti:
>> On Fri, Feb 19, 2010 at 12:22:58PM -0600, Christoph Lameter wrote:
>>> On Mon, 15 Feb 2010, Nick Piggin wrote:
>>>
>>>> I'm just worried there is still an underlying problem here.
>>> So am I. What caused the breakage that requires this patchset?
>>
>> Memory hotadd with a new node being onlined.
>
> So can you post the oops, please? Right now I am looking at zapping the 

I can't post the oops from a pre-release system.

> series from slab.git due to NAKs from both Christoph and Nick.

Huh? They just complained about the patch, not the whole series.
I don't understand how that could prompt you to drop the whole series.

As far as I know nobody said the patch is wrong so far, just
that they wanted to have more analysis.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
