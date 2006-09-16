Date: Sat, 16 Sep 2006 04:38:35 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916043835.5bc2552c.pj@sgi.com>
In-Reply-To: <200609160642.30153.ak@suse.de>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060915012810.81d9b0e3.akpm@osdl.org>
	<20060915203816.fd260a0b.pj@sgi.com>
	<200609160642.30153.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andi wrote:
> I'm currently back in the camp of liking it. It should be the fastest
> in the fast path as far as I know and the slow path code 
> is probably not as bad as I originally thought

Unfortunately, I don't think that this proposal, alternative (3) "The
custom zonelist option", handles the fake numa node case that Andrew is
raising with the desired performance.  For Andrew's particular load, it
would still have long zonelists that had to be scanned before finding a
node with free memory.


> (didn't you already have it coded up at some point?)

Yup - in the link I provided describing this:

  http://lkml.org/lkml/2005/11/5/252

there is a link to my original patch:

  http://lkml.org/lkml/2004/8/2/256

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
