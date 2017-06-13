Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22B306B036A
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:15:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m19so73376580pgd.14
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:15:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u5si9032760plm.352.2017.06.13.03.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 03:15:18 -0700 (PDT)
Message-ID: <593FBBBC.3060603@intel.com>
Date: Tue, 13 Jun 2017 18:17:32 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-7-git-send-email-wei.w.wang@intel.com> <db8cc3d1-50fc-2412-af2f-1070dda38be3@intel.com>
In-Reply-To: <db8cc3d1-50fc-2412-af2f-1070dda38be3@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/12/2017 10:07 PM, Dave Hansen wrote:
> On 06/09/2017 03:41 AM, Wei Wang wrote:
>> +	for_each_populated_zone(zone) {
>> +		for (order = MAX_ORDER - 1; order > 0; order--) {
>> +			for (migratetype = 0; migratetype < MIGRATE_TYPES;
>> +			     migratetype++) {
>> +				do {
>> +					ret = report_unused_page_block(zone,
>> +						order, migratetype, &page);
>> +					if (!ret) {
>> +						pfn = (u64)page_to_pfn(page);
>> +						add_one_chunk(vb, vq,
>> +						PAGE_CHNUK_UNUSED_PAGE,
>> +						pfn << VIRTIO_BALLOON_PFN_SHIFT,
>> +						(u64)(1 << order) *
>> +						VIRTIO_BALLOON_PAGES_PER_PAGE);
>> +					}
>> +				} while (!ret);
>> +			}
>> +		}
>> +	}
> This is pretty unreadable.    Please add some indentation.  If you go
> over 80 cols, then you might need to break this up into a separate
> function.  But, either way, it can't be left like this.

OK, I'll re-arrange it.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
