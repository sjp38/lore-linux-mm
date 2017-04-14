Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82A6B2806CB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 21:50:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r49so19612803qta.22
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 18:50:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i17si469478qkh.295.2017.04.13.18.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 18:50:55 -0700 (PDT)
Date: Fri, 14 Apr 2017 04:50:48 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
Message-ID: <20170414044515-mutt-send-email-mst@kernel.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <20170413204411.GJ784@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413204411.GJ784@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, Apr 13, 2017 at 01:44:11PM -0700, Matthew Wilcox wrote:
> On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
> > 2) transfer the guest unused pages to the host so that they
> > can be skipped to migrate in live migration.
> 
> I don't understand this second bit.  You leave the pages on the free list,
> and tell the host they're free.  What's preventing somebody else from
> allocating them and using them for something?  Is the guest semi-frozen
> at this point with just enough of it running to ask the balloon driver
> to do things?

There's missing documentation here.

The way things actually work is host sends to guest
a request for unused pages and then write-protects all memory.

So guest isn't frozen but any changes will be detected by host.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
