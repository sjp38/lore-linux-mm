Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 162E2831FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:11:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so97772395pfg.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:11:31 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f7si5603194pfe.81.2017.03.08.23.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 23:11:30 -0800 (PST)
Message-ID: <58C1006F.6080206@intel.com>
Date: Thu, 09 Mar 2017 15:12:47 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 kernel 2/5] virtio-balloon: VIRTIO_BALLOON_F_CHUNK_TRANSFER
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com> <1488519630-89058-3-git-send-email-wei.w.wang@intel.com> <20170308060131-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170308060131-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang.opensource@gmail.com>

On 03/08/2017 12:01 PM, Michael S. Tsirkin wrote:
> On Fri, Mar 03, 2017 at 01:40:27PM +0800, Wei Wang wrote:
>> From: Liang Li <liang.z.li@intel.com>
>>
>> Add a new feature bit, VIRTIO_BALLOON_F_CHUNK_TRANSFER. Please check
>> the implementation patch commit for details about this feature.
>
> better squash into next patch.

OK, will do.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
