Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89CCC6B05EF
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:33:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so189747742pfg.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:33:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u25si16354886pgn.515.2017.07.31.05.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 05:33:29 -0700 (PDT)
Message-ID: <597F2439.5070309@intel.com>
Date: Mon, 31 Jul 2017 20:36:09 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <59686EEB.8080805@intel.com> <20170723044036-mutt-send-email-mst@kernel.org> <59781119.8010200@intel.com> <20170726155856-mutt-send-email-mst@kernel.org> <597954E3.2070801@intel.com> <20170729020231-mutt-send-email-mst@kernel.org> <597C83CC.7060702@intel.com> <20170730043922-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F739288D85@shsmsx102.ccr.corp.intel.com> <20170730191735-mutt-send-email-mst@kernel.org> <20170730191911-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170730191911-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On 07/31/2017 12:20 AM, Michael S. Tsirkin wrote:
> On Sun, Jul 30, 2017 at 07:18:33PM +0300, Michael S. Tsirkin wrote:
>> On Sun, Jul 30, 2017 at 05:59:17AM +0000, Wang, Wei W wrote:
>> That's a hypervisor implementation detail. From guest point of view,
>> discarding contents can not be distinguished from writing old contents.
>>
> Besides, ignoring the free page tricks, consider regular ballooning.
> We map page with DONTNEED then back with WILLNEED. Result is
> getting a zero page. So at least one of deflate/inflate should be input.
> I'd say both for symmetry.
>

OK, I see the point. Thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
