Date: Wed, 24 Jul 2002 19:45:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725024535.GB2907@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au> <Pine.LNX.4.44L.0207241319550.3086-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0207241319550.3086-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2002, Andrew Morton wrote:
>> Then again, if the per-vma pfn->pte lookup is feasible, we may not need
>> the pte_chain at all...

On Wed, Jul 24, 2002 at 01:24:13PM -0300, Rik van Riel wrote:
> It is feasible, both davem and bcrl made code to this effect. The
> only problem with that code is that it gets ugly quick after mremap.

I actually took an axe to mremap recently, and althought the pieces
never came back together into working code, it's clear that it's far
from optimal. It's doing a virtual sweep over the region and repeating
the pgd -> pmd -> pte traversals for each pte. So invading that territory
may well be justifiable on more grounds than rmap itself.

I may revisit mremap.c at some point in the distant future if that
tweaking alone is considered valuable.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
