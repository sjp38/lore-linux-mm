Date: Wed, 31 Jul 2002 17:14:56 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: throttling dirtiers
Message-ID: <20020731171456.S10270@redhat.com>
References: <3D479F21.F08C406C@zip.com.au> <20020731200612.GJ29537@holomorphy.com> <20020731162357.Q10270@redhat.com> <3D48504B.9520455D@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D48504B.9520455D@zip.com.au>; from akpm@zip.com.au on Wed, Jul 31, 2002 at 02:02:03PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2002 at 02:02:03PM -0700, Andrew Morton wrote:
> But let's back off a bit.   The problem is that a process
> doing a large write() can penalise innocent processes which
> want to allocate memory.
> 
> How to fix that?

First off, make it obvious where we block in the allocation path (pawning 
off all memory reaping to kswapd et al is an easy first step here).  Then 
make allocators cycle through on a FIFO basis by using something like the 
page reservation patch I came up with a while ago.  That'll give us an 
easy place to change scheduling behaviour.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
