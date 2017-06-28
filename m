Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80F396B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:05:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s65so57865257pfi.14
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:05:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 4si414018pgj.249.2017.06.28.08.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 08:05:03 -0700 (PDT)
Date: Wed, 28 Jun 2017 08:04:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [virtio-dev] Re: [PATCH v11 3/6] virtio-balloon:
 VIRTIO_BALLOON_F_PAGE_CHUNKS
Message-ID: <20170628150450.GA1402@bombadil.infradead.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-4-git-send-email-wei.w.wang@intel.com>
 <20170613200049-mutt-send-email-mst@kernel.org>
 <594240E9.2070705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <594240E9.2070705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, Jun 15, 2017 at 04:10:17PM +0800, Wei Wang wrote:
> > So you still have a home-grown bitmap. I'd like to know why
> > isn't xbitmap suggested for this purpose by Matthew Wilcox
> > appropriate. Please add a comment explaining the requirements
> > from the data structure.
> 
> I didn't find his xbitmap being upstreamed, did you?

It doesn't have any users in the tree yet.  Can't add code with new users.
You should be the first!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
