Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DF72D62000C
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 00:23:07 -0500 (EST)
Date: Thu, 11 Feb 2010 13:22:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Remove unused macro, VM_MIN_READAHEAD.
Message-ID: <20100211052247.GA15392@localhost>
References: <201002091659.19988.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201002091659.19988.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi Nikanth,

On Tue, Feb 09, 2010 at 04:59:19PM +0530, Nikanth Karthikesan wrote:
> Remove unused macro, VM_MIN_READAHEAD.

NAK, sorry.

I'm using VM_MIN_READAHEAD in this patchset:

        http://lkml.org/lkml/2010/2/2/232

So please don't drop it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
