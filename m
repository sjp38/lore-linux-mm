Message-ID: <3D3F93A9.DBE4ED02@zip.com.au>
Date: Wed, 24 Jul 2002 22:59:05 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com> <3D3F893D.4074CDE5@zip.com.au> <20020725051552.GA48429@compsoc.man.ac.uk> <3D3F9103.FFC79916@zip.com.au> <20020725054203.GG2907@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: John Levon <levon@movementarian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> John Levon wrote:
> >> I wrote a patch some time ago to remove all this guesswork on lock call
> >> sites :
> >>
> 
> On Wed, Jul 24, 2002 at 10:47:47PM -0700, Andrew Morton wrote:
> > Me too, but I just killed all the out-of-line gunk, so the cost
> > is shown at the actual callsite.
> 
> It will be applied shortly. I've also been building with -g, so addr2line
> will resolve the rest given appropriate dumping formats.

Hope it still works.

> What's the op_time / oprofpp command that gives per-EIP sample frequencies?

I use

	oprofpp -L -i /boot/vmlinux

oprofile can also allegedly do eip->file-n-line resolution,
but I'm not sure how that works when you're cross-building.
And generally I doubt i it's useful for kernel stuff, because
the EIP usually resolves to something like test_and_set_bit().

So I just fire up gdb on vmlinux and walk up and down a few bytes until
the address->line resolution falls out of the inline function and
into the caller.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
