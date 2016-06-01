Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8099F6B0268
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:26:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so15273387pfb.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:26:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 187si20057491pff.129.2016.06.01.07.26.40
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 07:26:40 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:34:12 -0400
From: Keith Busch <keith.busch@intel.com>
Subject: Re: Re: why use alloc_workqueue instead of
 create_singlethread_workqueue to create nvme_workq
Message-ID: <20160601143412.GJ24107@localhost.localdomain>
References: <tencent_4323E1CE03D759181B6B4507@qq.com>
 <20160531145306.GB24107@localhost.localdomain>
 <2016060110542407705011@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2016060110542407705011@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "shhuiw@foxmail.com" <shhuiw@foxmail.com>
Cc: "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Wed, Jun 01, 2016 at 10:54:27AM +0800, shhuiw@foxmail.com wrote:
> Thanks, Keith!
> 
> Any idea on how to fix the warning? Just drop the WQ_MEM_RECLAIM for nvme_workq, or
> lru drain work schedule should be changed?

I sent request to lkml and linux-mm list, trying to resurrect this older
proposal from Tejun Heo:

  https://patchwork.ozlabs.org/patch/574623/

Not much interest yet, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
