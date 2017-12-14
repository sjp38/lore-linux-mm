Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7D76B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:58:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 3so3599247pfo.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:58:05 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id t1si2342454pgc.68.2017.12.13.20.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Dec 2017 20:58:04 -0800 (PST)
Date: Thu, 14 Dec 2017 15:58:00 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: d1fc031747 ("sched/wait: assert the wait_queue_head lock is
 .."):  EIP: __wake_up_common
Message-ID: <20171214155800.4f5376a5@canb.auug.org.au>
In-Reply-To: <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com>
	<20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com

Hi Andrew,

On Wed, 13 Dec 2017 17:03:00 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> I'm probably sitting on an older version.  I've dropped
> 
> epoll: use the waitqueue lock to protect ep->wq
> sched/wait: assert the wait_queue_head lock is held in __wake_up_common

Dropped from linux-next as well.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
