Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46B696B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:57:33 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so2545529wmd.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:57:33 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f9si3071314wrc.486.2017.12.14.04.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 04:57:32 -0800 (PST)
Date: Thu, 14 Dec 2017 13:57:31 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: d1fc031747 ("sched/wait: assert the wait_queue_head lock is
	.."):  EIP: __wake_up_common
Message-ID: <20171214125731.GA10676@lst.de>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com> <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Dec 13, 2017 at 05:03:00PM -0800, Andrew Morton wrote:
> I'm probably sitting on an older version.  I've dropped
> 
> epoll: use the waitqueue lock to protect ep->wq
> sched/wait: assert the wait_queue_head lock is held in __wake_up_common

Thanks.  I'll send a v3 over the fixed version with the nits pointed
out during review today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
