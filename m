Message-ID: <38918A88.5B8D05A@access.mountain.net>
Date: Fri, 28 Jan 2000 12:24:41 +0000
From: Tom Leete <tleete@access.mountain.net>
MIME-Version: 1.0
Subject: Re: [PATCH] boobytrap for 2.2.15pre5
References: <Pine.LNX.4.10.10001280155560.25452-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
[...] 
> If you apply this patch your kernel will spit out
> a one-line error message on every offence (and a
> 2-liner on a recursive offence). Each error message
> will be of the form:
> 
[...] 
> When you encounter these error messages, please send them
> to linux-kernel, _with_ the names of the functions (because
> they differ on every compilation) and, if possible, a short
> explanation of what do did to provoke these errors.
> 
>

Hi,

Got lots of these:
kmem_cache_alloc called from non-running (1) task from
c014d5e8!
then one of these:
kmem_cache_alloc called from non-running (2) task from
c014d5e8!

c014d5e8 is in alloc_skb.

ppp generates a lot of them, but not all. With ppp they seem
to be arriving in bursts of five at intervals of maybe 1 to
5 min. Those intervals are likely to reflect my activity. I
also got a few during startup or login.

net/core/skbuff.c says __GFP_WAIT  is clear if
in_interrupt(), but passes all other flags direct to
kmem_cache_alloc. I'm not seeing the printf(KERN_ERR ...)
for sleeping in interrupt from there.

Traces to follow, unless this rings a bell for someone.

Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
