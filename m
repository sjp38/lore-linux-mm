Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6FA2800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 04:42:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y63so5616833pff.5
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 01:42:50 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c21-v6si1743850plo.46.2018.01.25.01.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 01:42:49 -0800 (PST)
Message-ID: <5A69A72F.4000104@intel.com>
Date: Thu, 25 Jan 2018 17:45:19 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v24 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com> <1516790562-37889-3-git-send-email-wei.w.wang@intel.com> <20180124183349-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180124183349-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/25/2018 01:15 AM, Michael S. Tsirkin wrote:
> On Wed, Jan 24, 2018 at 06:42:42PM +0800, Wei Wang wrote:
>>   
>>
>> What is this doing? Basically handling the case where vq is broken?
>> It's kind of ugly to tweak feature bits, most code assumes they never
>> change.  Please just return an error to caller instead and handle it
>> there.
>>
>> You can then avoid sprinking the check for the feature bit
>> all over the code.
>>
>
> One thing I don't like about this one is that the previous request
> will still try to run to completion.
>
> And it all seems pretty complex.
>
> How about:
> - pass cmd id to a queued work
> - queued work gets that cmd id, stores a copy and uses that,
>    re-checking periodically - stop if cmd id changes:
>    will replace  report_free_page too since that's set to
>    stop.
>
> This means you do not reuse the queued cmd id also
> for the buffer - which is probably for the best.

Thanks for the suggestion. Please have a check how it's implemented in v25.
Just a little reminder that work queue has internally ensured that there 
is no re-entrant of the same queued function.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
