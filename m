Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81AB0C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EE0F20684
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:58:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EE0F20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7F0E8E0003; Fri,  8 Mar 2019 03:58:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2FC88E0002; Fri,  8 Mar 2019 03:58:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91DAD8E0003; Fri,  8 Mar 2019 03:58:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9AF8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 03:58:56 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z198so15524152qkb.15
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 00:58:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8OpvGNwcIL6WgQ4I+g11lCutlOE4M3O4RbmmA27gOis=;
        b=uP2cXMQLpeLeHfHZ1q5Zw7GXOSH2zn9nC/a5NEvpHsxDqtS2hB8snzU8YkOr8yikCI
         xv2n7i+7KMy90Lrhzps6Y3nEp6qxpHYVBMPaC+1jEnYFdidfiqyTWrBvnqH3QTmgq9uW
         rCjd1XPX2jR1zWfpUX3gPRQD0kwlGwbQfT+++e1rYOaPTFHx78lNJ2Obxku82mJiTOlk
         cn8tVzWphnI/jqRI1WzE86wZCWx+JYw3VGtpWLcPofga2OgFX3rdrV94d7ZCSDaVK6V2
         jTcI/fHpGG30iPJNdq50U28DOv8V3/zIRt1Jtu0SEfu+ujm5XqWJ1eWJ1ZyiOrq5LOJv
         5PlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6rXhGN1NJU0hCpMbRWulvUkTyUggwYcohjzhoV47nkq/ZMCi/
	1ooOBBIfAePcmZDBTluWzjwvGl9ayymRc3Oq1MBwQCslY5EuHjkVu9kTwwJZzQ4jJFuugL5/rBV
	9hWLhYd7B8FV42zhPfzVLimKRg8JIX5tbwGHDro8HoUKFyUAKi0j4qMc7AdWGBvksGw==
X-Received: by 2002:aed:2a6d:: with SMTP id k42mr14332799qtf.390.1552035536163;
        Fri, 08 Mar 2019 00:58:56 -0800 (PST)
X-Google-Smtp-Source: APXvYqyu0EfPxPCPKVWujc7Bzi0ZEfPEqLSVJWXImkTmll+QvNe48URqAMt56ICbaN8t+KL7kZfW
X-Received: by 2002:aed:2a6d:: with SMTP id k42mr14332764qtf.390.1552035535430;
        Fri, 08 Mar 2019 00:58:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552035535; cv=none;
        d=google.com; s=arc-20160816;
        b=VWSAQ1eqrzT48A3AYKeYA4fDQYcidEdsi8JSSv4A7bbZ2tHM2MGOS8i5E4ICuy/URx
         q7NrNU1o7SGnAaC1KUMx5VoAocAawknHI7a/eXz15TF/V+Sx0kWza/btUmxbm4J+ilRM
         I3+xq5m9TRFdBq2uMAey1BQ+4XhdRpolk4cLZR+nDX7E+O9Ou3p8taG8mf12Yt+rJ8BA
         KJLBJ/vrfhlBKe8TvxXD+Ko6KR3FnLRd/xKtapf5q+DajLcDCBGxP8BAPwXxvLzwId5Q
         pnrpw+JsSJxlO0bJUK/m7c0NIQv8CvZe1Us7Egf8i4TCFKLAAGo0is7Umv6OhpEZj28/
         5GZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8OpvGNwcIL6WgQ4I+g11lCutlOE4M3O4RbmmA27gOis=;
        b=y+cSq8k4pqFPYAHJ9q6kpdAFL8WgDuvSTSvtwT7LOAHSD0Y7oSousGRljq/EAYyaNW
         p9BQ4e1GdHf0kMT5N2Vbp8Q1E05iIoXhSuLEHi7lAUgtQ8RIMFXZ30nHb77FYVOL5ky6
         P2OhaMW5wX/Cgx5iGZb+GRNcH5XU5Ko6OBs2aYN6dYKQ1E8dg2Ae91uPzT6XFGCICKvt
         kWA/PR/tVg2nVyCapmdbockcnW18UOKJISwT7d3MQc0y1G5pnQ85m15AjFD6QH4ZqCze
         vq1Arg7HTfFqqiHRivsOnt+t1s/xRIxaT97aVX++OTx3HcVRBWh84A8sxZ+CcKqyGf0D
         ovng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s24si682477qta.16.2019.03.08.00.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 00:58:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A13FB308429D;
	Fri,  8 Mar 2019 08:58:54 +0000 (UTC)
Received: from [10.72.12.27] (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A4CD75D719;
	Fri,  8 Mar 2019 08:58:46 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Jerome Glisse <jglisse@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, aarcange@redhat.com
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <43408100-84d9-a359-3e78-dc65fb7b0ad1@redhat.com>
Date: Fri, 8 Mar 2019 16:58:44 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190307191720.GF3835@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 08 Mar 2019 08:58:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 上午3:17, Jerome Glisse wrote:
> On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
>> On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
>>>> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
>>>> +	.invalidate_range = vhost_invalidate_range,
>>>> +};
>>>> +
>>>>   void vhost_dev_init(struct vhost_dev *dev,
>>>>   		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>>>>   {
>>> I also wonder here: when page is write protected then
>>> it does not look like .invalidate_range is invoked.
>>>
>>> E.g. mm/ksm.c calls
>>>
>>> mmu_notifier_invalidate_range_start and
>>> mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
>>>
>>> Similarly, rmap in page_mkclean_one will not call
>>> mmu_notifier_invalidate_range.
>>>
>>> If I'm right vhost won't get notified when page is write-protected since you
>>> didn't install start/end notifiers. Note that end notifier can be called
>>> with page locked, so it's not as straight-forward as just adding a call.
>>> Writing into a write-protected page isn't a good idea.
>>>
>>> Note that documentation says:
>>> 	it is fine to delay the mmu_notifier_invalidate_range
>>> 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
>>> implying it's called just later.
>> OK I missed the fact that _end actually calls
>> mmu_notifier_invalidate_range internally. So that part is fine but the
>> fact that you are trying to take page lock under VQ mutex and take same
>> mutex within notifier probably means it's broken for ksm and rmap at
>> least since these call invalidate with lock taken.
>>
>> And generally, Andrea told me offline one can not take mutex under
>> the notifier callback. I CC'd Andrea for why.
> Correct, you _can not_ take mutex or any sleeping lock from within the
> invalidate_range callback as those callback happens under the page table
> spinlock. You can however do so under the invalidate_range_start call-
> back only if it is a blocking allow callback (there is a flag passdown
> with the invalidate_range_start callback if you are not allow to block
> then return EBUSY and the invalidation will be aborted).
>
>
>> That's a separate issue from set_page_dirty when memory is file backed.
> If you can access file back page then i suggest using set_page_dirty
> from within a special version of vunmap() so that when you vunmap you
> set the page dirty without taking page lock. It is safe to do so
> always from within an mmu notifier callback if you had the page map
> with write permission which means that the page had write permission
> in the userspace pte too and thus it having dirty pte is expected
> and calling set_page_dirty on the page is allowed without any lock.
> Locking will happen once the userspace pte are tear down through the
> page table lock.


Can I simply can set_page_dirty() before vunmap() in the mmu notifier 
callback, or is there any reason that it must be called within vumap()?

Thanks


>
>> It's because of all these issues that I preferred just accessing
>> userspace memory and handling faults. Unfortunately there does not
>> appear to exist an API that whitelists a specific driver along the lines
>> of "I checked this code for speculative info leaks, don't add barriers
>> on data path please".
> Maybe it would be better to explore adding such helper then remapping
> page into kernel address space ?
>
> Cheers,
> Jérôme

