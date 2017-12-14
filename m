Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78E586B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:03:04 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g80so2244716wrd.17
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:03:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d187si2465154wme.168.2017.12.13.17.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 17:03:03 -0800 (PST)
Date: Wed, 13 Dec 2017 17:03:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: d1fc031747
 ("sched/wait: assert the wait_queue_head lock is .."):  EIP:
 __wake_up_common
Message-Id: <20171213170300.b0bb26900dd00641819b4872@linux-foundation.org>
In-Reply-To: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com>
References: <5a31cac7.i9WLKx5al8+rBn73%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, 14 Dec 2017 08:50:15 +0800 kernel test robot <fengguang.wu@intel.com> wrote:

> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> 
> commit d1fc0317472217762fa7741260ca464077b4c877
> Author:     Christoph Hellwig <hch@lst.de>
> AuthorDate: Wed Dec 13 11:52:12 2017 +1100
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Wed Dec 13 16:04:58 2017 +1100
> 
>     sched/wait: assert the wait_queue_head lock is held in __wake_up_common
>     
>     Better ensure we actually hold the lock using lockdep than just commenting
>     on it.  Due to the various exported _locked interfaces it is far too easy
>     to get the locking wrong.

I'm probably sitting on an older version.  I've dropped

epoll: use the waitqueue lock to protect ep->wq
sched/wait: assert the wait_queue_head lock is held in __wake_up_common

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
