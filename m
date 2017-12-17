Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFD946B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 05:22:29 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r140so6084266iod.12
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 02:22:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 97si7270778iod.195.2017.12.17.02.22.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Dec 2017 02:22:28 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
	<20171215184256.GA27160@bombadil.infradead.org>
	<5A34F193.5040700@intel.com>
	<201712162028.FEB87079.FOJFMQHVOSLtFO@I-love.SAKURA.ne.jp>
	<5A35FF89.8040500@intel.com>
In-Reply-To: <5A35FF89.8040500@intel.com>
Message-Id: <201712171921.IBB30790.VOOOFMQHFSLFJt@I-love.SAKURA.ne.jp>
Date: Sun, 17 Dec 2017 19:21:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> > But passing GFP_NOWAIT means that we can handle allocation failure. There is
> > no need to use preload approach when we can handle allocation failure.
> 
> I think the reason we need xb_preload is because radix tree insertion 
> needs the memory being preallocated already (it couldn't suffer from 
> memory failure during the process of inserting, probably because 
> handling the failure there isn't easy, Matthew may know the backstory of 
> this)

According to https://lwn.net/Articles/175432/ , I think that preloading is needed
only when failure to insert an item into a radix tree is a significant problem.
That is, when failure to insert an item into a radix tree is not a problem,
I think that we don't need to use preloading.

> 
> So, I think we can handle the memory failure with xb_preload, which 
> stops going into the radix tree APIs, but shouldn't call radix tree APIs 
> without the related memory preallocated.

It seems to me that virtio-ballon case has no problem without using preloading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
