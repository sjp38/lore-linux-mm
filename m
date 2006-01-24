From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Tue, 24 Jan 2006 01:39:46 +0100
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <200601231758.08397.raybry@mpdtxmail.amd.com> <200601231816.38942.raybry@mpdtxmail.amd.com>
In-Reply-To: <200601231816.38942.raybry@mpdtxmail.amd.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601240139.46751.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 January 2006 01:16, Ray Bryant wrote:
> On Monday 23 January 2006 17:58, Ray Bryant wrote:
> <snip>
> 
> > ... And what kind of alignment constraints do we end up
> > under in order to make the sharing happen?   (My guess would be that there
> > aren't any such constraints (well, page alignment.. :-)  if we are just
> > sharing pte's.)
> >
> 
> Oh, obviously that is not right as you have to share full pte pages.   So on 
> x86_64 I'm guessing one needs 2MB alignment in order to get the sharing to
> kick in, since a pte page maps 512 pages of 4 KB each.

The new randomized mmaps will likely actively sabotate such alignment. I just
added them for x86-64.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
