Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B02F6B0038
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 22:26:54 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id h72so64042119iod.0
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 19:26:54 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n129si1047666itd.2.2017.04.13.19.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 19:26:53 -0700 (PDT)
Message-ID: <58F033D0.7080101@intel.com>
Date: Fri, 14 Apr 2017 10:28:32 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com> <20170413204411.GJ784@bombadil.infradead.org> <20170414044515-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170414044515-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 04/14/2017 09:50 AM, Michael S. Tsirkin wrote:
> On Thu, Apr 13, 2017 at 01:44:11PM -0700, Matthew Wilcox wrote:
>> On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
>>> 2) transfer the guest unused pages to the host so that they
>>> can be skipped to migrate in live migration.
>> I don't understand this second bit.  You leave the pages on the free list,
>> and tell the host they're free.  What's preventing somebody else from
>> allocating them and using them for something?  Is the guest semi-frozen
>> at this point with just enough of it running to ask the balloon driver
>> to do things?
> There's missing documentation here.
>
> The way things actually work is host sends to guest
> a request for unused pages and then write-protects all memory.
>
> So guest isn't frozen but any changes will be detected by host.
>

Probably it's better to say " transfer the info about the guest unused pages
to the host so that the host gets a chance to skip the transfer of the 
unused
pages during live migration".

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
