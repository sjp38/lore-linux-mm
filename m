Date: Thu, 18 Sep 2003 10:08:56 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: __vmalloc and alloc_page
Message-ID: <20030918170856.GT14079@holomorphy.com>
References: <200309171326.11848.lmb@exatas.unisinos.br> <20030917193202.GG14079@holomorphy.com> <200309181320.08605.lmb@exatas.unisinos.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309181320.08605.lmb@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leandro Motta Barros <lmb@exatas.unisinos.br>
Cc: linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

On Wednesday 17 September 2003 16:32, William Lee Irwin III wrote:
>> Higher-order would probably not be as useful as you'd suspect; try
>> looking at the distribution of available pages of given sizes in /proc/.
>> OTOH, just being able to get more than one page in one call (not relying
>> on physically contiguous memory) would be a simple and useful optimization.

On Thu, Sep 18, 2003 at 01:20:08PM -0300, Leandro Motta Barros wrote:
> I'm not sure if I really understood what you said. Does it means that in some 
> cases (e.g., when the buddy allocator has a free chunk of the proper size) 
> this could be good, even though this will not help other things (like 
> reducing the number of splits in the buddy allocator)?

No.

Relying on there being contiguous memory means it will fail more often
than it has to and/or does now.

The suggestion was to add an interface to fetch more than one page in
one call, to reduce various kinds of overheads associated with the round
trip through the codepaths (dis/re -enabling ints, ticking counters, etc.)


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
