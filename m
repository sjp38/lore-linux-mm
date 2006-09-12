Date: Mon, 11 Sep 2006 20:07:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A solution for more GFP_xx flags?
In-Reply-To: <87bqplaiok.wl%peterc@quokka.chubb.wattle.id.au>
Message-ID: <Pine.LNX.4.64.0609112006220.7923@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
 <45061F16.202@yahoo.com.au> <Pine.LNX.4.64.0609111957510.7923@schroedinger.engr.sgi.com>
 <87bqplaiok.wl%peterc@quokka.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2006, Peter Chubb wrote:

> Dunno about you, but the thought of passing structs around on the
> stack gives me the heebie jeebies, especially if they're going to be
> more than a word or so big.

Right.
 
> Either pass by reference, or separate out the args, so it's explicit
> how much info's being copied around.

Maybe I misunderstood Nick but I did not think he was proposing pushing 
structs on the stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
