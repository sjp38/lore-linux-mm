Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27CD96B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:05:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p9so6194115pgc.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:05:06 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m66si4209600pfb.72.2017.10.19.01.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 01:05:05 -0700 (PDT)
Message-ID: <59E85D2A.1060407@intel.com>
Date: Thu, 19 Oct 2017 16:07:06 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com> <1506744354-20979-6-git-send-email-wei.w.wang@intel.com> <20171001060305-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com> <20171010180636-mutt-send-email-mst@kernel.org> <59DDB428.4020208@intel.com> <20171011161912-mutt-send-email-mst@kernel.org> <59DEE790.5040809@intel.com> <20171013163503-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171013163503-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On 10/13/2017 09:38 PM, Michael S. Tsirkin wrote:
> On Thu, Oct 12, 2017 at 11:54:56AM +0800, Wei Wang wrote:
>>> But I think flushing is very fragile. You will easily run into races
>>> if one of the actors gets out of sync and keeps adding data.
>>> I think adding an ID in the free vq stream is a more robust
>>> approach.
>>>
>> Adding ID to the free vq would need the device to distinguish whether it
>> receives an ID or a free page hint,
> Not really.  It's pretty simple: a 64 bit buffer is an ID. A 4K and bigger one
> is a page.

I think we can also use the previous method, free page via in_buf, and 
id via out_buf.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
