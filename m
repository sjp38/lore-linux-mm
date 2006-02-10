From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v22
Date: Fri, 10 Feb 2006 12:04:12 +1100
References: <200602092339.49719.kernel@kolivas.org> <43EB43B9.5040001@yahoo.com.au> <200602100151.40894.kernel@kolivas.org>
In-Reply-To: <200602100151.40894.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602101204.12834.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Friday 10 February 2006 01:51, Con Kolivas wrote:
> On Friday 10 February 2006 00:29, Nick Piggin wrote:
> > busy Con Kolivas wrote:
> > > +	struct radix_tree_root	swap_tree;	/* Lookup tree of pages */
> >
> > Umm... what is swap_tree for, exactly?
>
> To avoid ...
>
> /me looks around
>
> It's because...
>
> /me scratches head
>
> wtf..
>
> /me comes up with the answer
>
> legacy that must die

Ah now I remember. To not iterate over the whole list when removing entries 
from the swapped list.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
