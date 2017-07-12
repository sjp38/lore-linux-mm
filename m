Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9466B0543
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 09:03:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y62so22857293pfa.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 06:03:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s185si1941899pgb.377.2017.07.12.06.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 06:03:16 -0700 (PDT)
Message-ID: <59661EA2.2040708@intel.com>
Date: Wed, 12 Jul 2017 21:05:38 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v11 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-4-git-send-email-wei.w.wang@intel.com> <20170613200049-mutt-send-email-mst@kernel.org> <594240E9.2070705@intel.com> <20170628150450.GA1402@bombadil.infradead.org>
In-Reply-To: <20170628150450.GA1402@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

Hi Matthew,

On 06/28/2017 11:04 PM, Matthew Wilcox wrote:
> On Thu, Jun 15, 2017 at 04:10:17PM +0800, Wei Wang wrote:
>>> So you still have a home-grown bitmap. I'd like to know why
>>> isn't xbitmap suggested for this purpose by Matthew Wilcox
>>> appropriate. Please add a comment explaining the requirements
>>> from the data structure.
>> I didn't find his xbitmap being upstreamed, did you?
> It doesn't have any users in the tree yet.  Can't add code with new users.
> You should be the first!

Glad to be the first person eating your tomato. Taste good :-)
Please have a check how it's cooked in the latest v12 patches. Thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
