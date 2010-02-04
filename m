Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 67C456004A5
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 03:24:58 -0500 (EST)
Message-ID: <4B6A8455.5010403@ladisch.de>
Date: Thu, 04 Feb 2010 09:24:53 +0100
From: Clemens Ladisch <clemens@ladisch.de>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] readahead: limit readahead size for small devices
References: <20100202152835.683907822@intel.com> <20100202153316.375570078@intel.com>
In-Reply-To: <20100202153316.375570078@intel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> Anyone has 512/128MB USB stick?

64 MB, USB full speed:
Bus 003 Device 003: ID 08ec:0011 M-Systems Flash Disk Pioneers DiskOnKey

4KB:    139.339 s, 376 kB/s
16KB:   81.0427 s, 647 kB/s
32KB:   71.8513 s, 730 kB/s
64KB:   67.3872 s, 778 kB/s
128KB:  67.5434 s, 776 kB/s
256KB:  65.9019 s, 796 kB/s
512KB:  66.2282 s, 792 kB/s
1024KB: 67.4632 s, 777 kB/s
2048KB: 69.9759 s, 749 kB/s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
