Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9166C6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 00:06:40 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o17so1701367pli.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:06:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o33si6064271plb.588.2017.12.15.21.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 21:06:39 -0800 (PST)
Date: Fri, 15 Dec 2017 21:05:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171216050536.GA18920@bombadil.infradead.org>
References: <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
 <20171214181219.GA26124@bombadil.infradead.org>
 <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
 <20171215202238-mutt-send-email-mst@kernel.org>
 <201712161331.ABI26579.OtOMFSOLHVFFQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712161331.ABI26579.OtOMFSOLHVFFQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mst@redhat.com, wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Sat, Dec 16, 2017 at 01:31:24PM +0900, Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
> > On Sat, Dec 16, 2017 at 01:21:52AM +0900, Tetsuo Handa wrote:
> > > My understanding is that virtio-balloon wants to handle sparsely spreaded
> > > unsigned long values (which is PATCH 4/7) and wants to find all chunks of
> > > consecutive "1" bits efficiently. Therefore, I guess that holding the values
> > > in ascending order at store time is faster than sorting the values at read
> > > time.

What makes you think that the radix tree (also xbitmap, also idr) doesn't
sort the values at store time?

> I'm asking whether we really need to invent a new library module (i.e.
> PATCH 1/7 + PATCH 2/7 + PATCH 3/7) for virtio-balloon compared to mine.
> 
> What virtio-balloon needs is ability to
> 
>   (1) record any integer value in [0, ULONG_MAX] range
> 
>   (2) fetch all recorded values, with consecutive values combined in
>       min,max (or start,count) form for efficiently
> 
> and I wonder whether we need to invent complete API set which
> Matthew Wilcox and Wei Wang are planning for generic purpose.

The xbitmap absolutely has that ability.  And making it generic code
means more people see it, use it, debug it, optimise it.  I originally
wrote the implementation for bcache, when Kent was complaining we didn't
have such a thing.  His needs weren't as complex as Wei's, which is why
I hadn't implemented everything that Wei needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
