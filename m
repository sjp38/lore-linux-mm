Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9C2E56B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:54:23 -0500 (EST)
Date: Wed, 20 Feb 2013 08:54:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: behavior of zram stats, and zram allocation limit
Message-ID: <20130219235421.GC16950@blaptop>
References: <CAA25o9Q4gMPeLf3uYJzMNR1EU4D3OPeje24X4PNsUVHGoqyY5g@mail.gmail.com>
 <20121123055144.GC13626@bbox>
 <51204DB1.9000203@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51204DB1.9000203@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Sun, Feb 17, 2013 at 11:25:37AM +0800, Jaegeuk Hanse wrote:
> On 11/23/2012 01:51 PM, Minchan Kim wrote:
> >On Wed, Nov 21, 2012 at 02:58:48PM -0800, Luigi Semenzato wrote:
> >>Hi,
> >>
> >>Two questions for zram developers/users.  (Please let me know if it is
> >>NOT acceptable to use this list for these questions.)
> >>
> >>1. When I run a synthetic load using zram from kernel 3.4.0,
> >>compr_data_size from /sys/block/zram0 seems to decrease even though
> >>orig_data_size stays constant (see below).  Is this a bug that was
> >>fixed in a later release?  (The synthetic load is a bunch of processes
> >>that allocate memory, fill half of it with data from /dev/urandom, and
> >>touch the memory randomly.)  I looked at the code and it looks right.
> >>:-P
> >>
> >>2. Is there a way of setting the max amount of RAM that zram is
> >>allowed to allocate?  Right now I can set the size of the
> >>*uncompressed* swap device, but how much memory gets allocated depends
> >>on the compression ratio, which could vary.
> >There is no method to limit the RAM size but I think we can implement
> >it easily. The only thing we need is just a "voice of customer".
> >Why do you need it?
> 
> But in current codes, where implement limit to *uncompressed* swap
> device? I can't find it in zram_drv.c, could you point out to me?

Swap layer would manage it by get_swap_page.

- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
