Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A82AD6B0082
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 08:01:10 -0500 (EST)
Date: Thu, 4 Feb 2010 21:00:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/11] readahead: limit readahead size for small devices
Message-ID: <20100204130056.GB25905@localhost>
References: <20100202152835.683907822@intel.com> <20100202153316.375570078@intel.com> <4B6A8455.5010403@ladisch.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B6A8455.5010403@ladisch.de>
Sender: owner-linux-mm@kvack.org
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Clemens,

Thanks for the data!

On Thu, Feb 04, 2010 at 04:24:53PM +0800, Clemens Ladisch wrote:
> Wu Fengguang wrote:
> > Anyone has 512/128MB USB stick?
> 
> 64 MB, USB full speed:
> Bus 003 Device 003: ID 08ec:0011 M-Systems Flash Disk Pioneers DiskOnKey
> 
> 4KB:    139.339 s, 376 kB/s
> 16KB:   81.0427 s, 647 kB/s
> 32KB:   71.8513 s, 730 kB/s
> 64KB:   67.3872 s, 778 kB/s
> 128KB:  67.5434 s, 776 kB/s
> 256KB:  65.9019 s, 796 kB/s
> 512KB:  66.2282 s, 792 kB/s
> 1024KB: 67.4632 s, 777 kB/s
> 2048KB: 69.9759 s, 749 kB/s

It seems to reach good throughput at 64KB readahead size :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
