Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 299CC8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:46:52 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n64-v6so2952299qkd.10
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:46:52 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id u9-v6si1703409qtk.133.2018.09.27.08.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 08:46:51 -0700 (PDT)
Date: Thu, 27 Sep 2018 17:46:47 +0200
From: Greg KH <gregkh@linux-foundation.org>
Subject: Re: [STABLE PATCH] slub: make ->cpu_partial unsigned int
Message-ID: <20180927154647.GB31654@kroah.com>
References: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: iamjoonsoo.kim@lge.com, rientjes@google.com, cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Sep 27, 2018 at 10:43:40PM +0800, zhong jiang wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
>         /*
>          * cpu_partial determined the maximum number of objects
>          * kept in the per cpu partial lists of a processor.
>          */
> 
> Can't be negative.
> 
> I hit a real issue that it will result in a large number of memory leak.
> Because Freeing slabs are in interrupt context. So it can trigger this issue.
> put_cpu_partial can be interrupted more than once.
> due to a union struct of lru and pobjects in struct page, when other core handles
> page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
> result in pobjects being a negative value(0xdead0000). Therefore, a large number
> of slabs will be added to per_cpu partial list.
> 
> I had posted the issue to community before. The detailed issue description is as follows.
> 
> Link: https://www.spinics.net/lists/kernel/msg2870979.html
> 
> After applying the patch, The issue is fixed. So the patch is a effective bugfix.
> It should go into stable.

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
