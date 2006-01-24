From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Mon, 23 Jan 2006 18:53:54 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231816.38942.raybry@mpdtxmail.amd.com>
 <200601240139.46751.ak@suse.de>
In-Reply-To: <200601240139.46751.ak@suse.de>
MIME-Version: 1.0
Message-ID: <200601231853.54948.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Dave McCracken <dmccr@us.ibm.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 23 January 2006 18:39, Andi Kleen wrote:
> On Tuesday 24 January 2006 01:16, Ray Bryant wrote:
> > On Monday 23 January 2006 17:58, Ray Bryant wrote:
> > <snip>
> >
> > > ... And what kind of alignment constraints do we end up
> > > under in order to make the sharing happen?   (My guess would be that
> > > there aren't any such constraints (well, page alignment.. :-)  if we
> > > are just sharing pte's.)
> >
> > Oh, obviously that is not right as you have to share full pte pages.   So
> > on x86_64 I'm guessing one needs 2MB alignment in order to get the
> > sharing to kick in, since a pte page maps 512 pages of 4 KB each.
>
> The new randomized mmaps will likely actively sabotate such alignment. I
> just added them for x86-64.
>
> -Andi

Hmmm, does that mean there is a fundamental conflict between the desire to 
share pte's and getting good cache coloring behavior?

Isn't it the case that if the region is large enough (say >> 2MB), that 
randomized mmaps will just cause the first partial page of pte's to not be 
shareable, and as soon as we have a full pte page mapped into the file that 
the full pte pages will be shareable, etc, until the last (partial) pte page 
is not shareable?

> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
