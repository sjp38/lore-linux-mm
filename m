From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911041848.KAA55976@google.engr.sgi.com>
Subject: Re: The 4GB memory thing
Date: Thu, 4 Nov 1999 10:48:20 -0800 (PST)
In-Reply-To: <m3aeou9l1y.fsf@alpha.random> from "Andrea Arcangeli" at Nov 4, 99 07:19:21 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: nconway.list@ukaea.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> 
> > I have a 2.2 patch for 4Gb support, which has seen a lot of stress
> > testing by now. The 2.3 >2gb support uses a different (and better
> > approach), but last I checked, things like rawio did not work above
> > >2Gb. The 64Gb support is completely new ...
> 
> 2.2.13aa3 includes both 4g bigmem support and rawio and you can do
> rawio on all the memory (bigmem included).
> 
> 	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.13aa3/
> 
> This is the README on how to go in sync with 2.2.13aa3:
> 
> 	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/tools/apply-patches/README.gz
> 
> -- 
> Andrea
> 

I don't see a README.gz under 
 http://www.kernel.org/pub/linux/kernel/people/andrea/tools/apply-patches/

In any case, did you a have a small technical README on how rawio works
on bigmem in 2.2.13aa3? Btw, I haven't seen the rawio 2.2 port, I am 
assuming its very similar to 2.3 ... where brw_kiovec() refuses to 
accept PageHighMem pages. I didn't see anything in z-bigmem-2.2.13aa3-7
that tinkers either with fs/buffer.c.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
