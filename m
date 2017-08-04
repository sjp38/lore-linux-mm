Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1B886B072F
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:52:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r13so11235003pfd.14
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:52:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 3si818152plt.612.2017.08.04.01.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 01:52:40 -0700 (PDT)
Message-ID: <5984367A.3030809@intel.com>
Date: Fri, 04 Aug 2017 16:55:22 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
References: <59830897.2060203@intel.com> <20170803112831.GN12521@dhcp22.suse.cz> <5983130E.2070806@intel.com> <20170803124106.GR12521@dhcp22.suse.cz> <59832265.1040805@intel.com> <20170803135047.GV12521@dhcp22.suse.cz> <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com> <20170804000043-mutt-send-email-mst@kernel.org> <20170804075337.GC26029@dhcp22.suse.cz> <59842D1C.5020608@intel.com> <20170804082423.GG26029@dhcp22.suse.cz>
In-Reply-To: <20170804082423.GG26029@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On 08/04/2017 04:24 PM, Michal Hocko wrote:
>
>> For our use case, the callback just puts the reported page
>> block to the ring, then returns. If the ring is full as the host
>> is busy, then I think it should skip this one, and just return.
>> Because:
>>      A. This is an optimization feature, losing a couple of free
>>           pages to report isn't that important;
>>      B. In reality, I think it's uncommon to see this ring getting
>>          full (I didn't observe ring full in the tests), since the host
>>          (consumer) is notified to take out the page block right
>>          after it is added.
> I thought you only updated a pre allocated bitmat... Anyway, I cannot
> comment on this part much as I am not familiar with your usecase.
>   

Actually the bitmap is in the hypervisor (host). The callback puts the
(pfn,size) on a ring which is shared with the hypervisor, then the
hypervisor takes that info from the ring and updates that bitmap.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
