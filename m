Message-ID: <3D2F28B5.5C7C227D@zip.com.au>
Date: Fri, 12 Jul 2002 12:06:29 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <Pine.LNX.4.44L.0207112011150.14432-100000@imladris.surriel.com> <Pine.LNX.4.33.0207121323230.13816-100000@eclipse.ltc.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> I've tried booting this patch on 2.5.25+rmap on an 8-way, with highmem.  I
> got a loot of oops on boot (couldn't see the top one because it scrolled
> off the screen) and I havn't had time to set it up with serial console yet
> but I will.

you could stick a `for(;;);' in arch/i386/kernel/traps.c:die() to
stop the scrolling...

I was using Dave's patch for several hours yesterday, no probs.

>  Before I do that though I wanted to know if there are any
> known issues with my configuration.  I vaguely remember someone mentioning
> problems with multiple swap partitions a while back and that's what I have
> 
> /etc/fstab:
> /dev/sda5               swap                    swap    defaults        0 0
> /dev/sda6               swap                    swap    defaults        0 0
> /dev/sda7               swap                    swap    defaults        0 0
> /dev/sda8               swap                    swap    defaults        0 0
> /dev/sda9               swap                    swap    defaults        0 0
> /dev/sda10              swap                    swap    defaults        0 0
> /dev/sda11              swap                    swap    defaults        0 0
> /dev/sda12              swap                    swap    defaults        0 0
> 
> for a total of about 15GB swap.

In theory the limits are:

Max of 32 swapdevs
Max of 64G per swapdev.

I normally use two equal-priority disks for swap.  Works OK, but I did
considerable futzing in the swap code a while back so some bugs may have
been added.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
