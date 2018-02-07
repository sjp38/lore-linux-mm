Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 497C36B02D8
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 02:24:01 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id w24so3149997plq.11
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 23:24:01 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g129si696776pfc.338.2018.02.06.23.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 23:24:00 -0800 (PST)
Message-ID: <5A7AAA2E.5090809@intel.com>
Date: Wed, 07 Feb 2018 15:26:38 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v26 2/2 RESEND] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1517972467-14352-1-git-send-email-wei.w.wang@intel.com> <20180207062846-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180207062846-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On 02/07/2018 12:34 PM, Michael S. Tsirkin wrote:
> On Wed, Feb 07, 2018 at 11:01:06AM +0800, Wei Wang wrote:
>> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
>> support of reporting hints of guest free pages to host via virtio-balloon.
>>
>> Host requests the guest to report free page hints by sending a new cmd
>> id to the guest via the free_page_report_cmd_id configuration register.
>>
>> When the guest starts to report, the first element added to the free page
>> vq is the cmd id given by host. When the guest finishes the reporting
>> of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
>> to the vq to tell host that the reporting is done. Host polls the free
>> page vq after sending the starting cmd id, so the guest doesn't need to
>> kick after filling an element to the vq.
>>
>> Host may also requests the guest to stop the reporting in advance by
>> sending the stop cmd id to the guest via the configuration register.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> ---
>>   drivers/virtio/virtio_balloon.c     | 255 +++++++++++++++++++++++++++++++-----
>>   include/uapi/linux/virtio_balloon.h |   7 +
>>   mm/page_poison.c                    |   6 +
>>   3 files changed, 232 insertions(+), 36 deletions(-)
>>
>> Resend Change:
>> 	- Expose page_poisoning_enabled to kernel modules
> RESEND tag is for reposting unchanged patches.
> you want to post a v27, and you want the mm patch
> as a separate one, so you can get an ack on it from
> someone on linux-mm.
>
> In fact, I would probably add reporting the poison value as
> a separate feature/couple of patches.
>

OK. I have made them separate patches in v27. Thanks a lot for reviewing 
so many versions, I learned a lot from the comments and discussion.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
