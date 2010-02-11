Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9376B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 18:44:14 -0500 (EST)
Date: Thu, 11 Feb 2010 23:42:49 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 03/11] readahead: bump up the default readahead size
Message-ID: <20100211234249.GE407@shareable.org>
References: <20100207041013.891441102@intel.com> <20100207041043.147345346@intel.com> <4B6FBB3F.4010701@linux.vnet.ibm.com> <20100208134634.GA3024@localhost> <1265924254.15603.79.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1265924254.15603.79.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, David Woodhouse <dwmw2@infradead.org>, linux-embedded@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
> On Mon, 2010-02-08 at 21:46 +0800, Wu Fengguang wrote:
> > Chris,
> > 
> > Firstly inform the linux-embedded maintainers :)
> > 
> > I think it's a good suggestion to add a config option
> > (CONFIG_READAHEAD_SIZE). Will update the patch..
> 
> I don't have a strong opinion here beyond the nagging feeling that we
> should be using a per-bdev scaling window scheme rather than something
> static.

I agree with both.  100Mb/s isn't typical on little devices, even if a
fast ATA disk is attached.  I've got something here where the ATA
interface itself (on a SoC) gets about 10MB/s max when doing nothing
else, or 4MB/s when talking to the network at the same time.
It's not a modern design, but you know, it's junk we try to use :-)

It sounds like a calculation based on throughput and seek time or IOP
rate, and maybe clamped if memory is small, would be good.

Is the window size something that could be meaningfully adjusted
according to live measurements?

-- Jamie



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
