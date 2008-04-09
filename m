Date: Wed, 9 Apr 2008 19:56:29 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [12/18] Add support to allocate hugetlb pages that are larger than MAX_ORDER
Message-ID: <20080409175629.GE30885@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015826.110AA1B41E0@basil.firstfloor.org> <47FCE93D.4090509@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47FCE93D.4090509@cray.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Hastings <abh@cray.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> This looks like an off-by-one error here and in the code below -- it 
> should be ">= MAX_ORDER" not "> MAX_ORDER".  Cf alloc_pages() in gfp.h:
> 
>         if (unlikely(order >= MAX_ORDER))
>                 return NULL;

True good point. Although it will only matter if some architecture
has MAX_ORDER sized huge pages :) x86-64 definitely hasn't.

I passed this code over to Nick so he'll hopefully incorporate the fix.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
