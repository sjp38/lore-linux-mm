Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Wed, 29 Aug 2001 17:13:59 +0200
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010828000128Z16263-32386+166@humbolt.nl.linux.org> <3B8CF2BA.5030506@syntegra.com>
In-Reply-To: <3B8CF2BA.5030506@syntegra.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010829150716Z16100-32383+2280@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Kay <Andrew.J.Kay@syntegra.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 29, 2001 03:48 pm, Andrew Kay wrote:
> Here's some 'cut' output from /var/log/messages.  There is a lot more 
> from where this came from.  Some of it looks a bit different, I included 
> it below the first 3 errors.  I can post the 165k gzipped messages file 
> somewhere if someone wants to look at the whole thing.
> 
> __alloc_pages: 1-order allocation failed (gfp=0x20/0).
> Call Trace: [<c012db70>] [<c012de1e>] [<c012a69e>] [<c012aa21>] 
> [<c0211032>]
>     [<c02392da>] [<c023669f>] [<c02355c1>] [<c02399a1>] [<c01b000f>] 
> [<c011c9bc>]
>     [<c01b000f>] [<c02158e6>] [<c021a714>] [<c02158e6>] [<c022173d>] 
> [<c0221638>]
>     [<c0221b5d>] [<c0211f53>] [<c0221638>] [<c023099a>] [<c0211f53>] 
> [<c0211f68>]
>     [<c02120b9>] [<c023698e>] [<c0236c65>] [<c023711d>] [<c021f07f>] 
> [<c021f40a>]
>     [<c01b0571>] [<c0215fae>] [<c0119533>] [<c0108785>] [<c0105230>] 
> [<c0105230>]
>     [<c0106e34>] [<c0105230>] [<c0105230>] [<c010525c>] [<c01052c2>] 
> [<c0105000>]
>     [<c010505f>]
> [similar]
>
> Daniel Phillips wrote:
> > On August 28, 2001 12:28 am, Marcelo Tosatti wrote:
> > 
> >>On Tue, 28 Aug 2001, Daniel Phillips wrote:
> >>
> >>>On August 27, 2001 10:14 pm, Andrew Kay wrote:
> >>>
> >>>>I am having some rather serious problems with the memory management (i 
> >>>>think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots 
> >>>>of these errors in /var/log/messages.
> >>>>
> >>Its probably the bounce buffering thingie.
> >>
> >>I'll send a patch to Linus soon.
> >>
> > 
> > That's what I thought too, but I thought, why not give him the patch and be 
> > sure.

OK, it's not a bounce buffer because the allocation isn't __GFP_WAIT (0x10).
It's GFP_ATOMIC and there are several hundred of those throughout the kernel so
I'm not going to try to guess which one.  Could you please pass a few of your
backtraces through ksymoops make them meaningful?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
