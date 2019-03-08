Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C7E7C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 09:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFAF22085A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 09:16:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFAF22085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9140E8E0003; Fri,  8 Mar 2019 04:16:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C3448E0002; Fri,  8 Mar 2019 04:16:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D9D18E0003; Fri,  8 Mar 2019 04:16:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 557AA8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 04:16:11 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k29so2348989qta.13
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 01:16:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AKLLDxfHKqFNNXyshRcVxMgpIFN0qim6aujHLqnxi/0=;
        b=fStbewpnmg/puGmZN2BqE8Hy6gZRYFe9egIcXMYkA+68dx30RYE/6zbTX1ZVFPedWJ
         MmKnBcWbIADz3PoFEb6yMUaj55s57gG9Xx3udYUiA2CBeTDaWN86JLMfxHG7jmq77T7A
         xzzYlEHMwwP78yK4JOIrR25BeHcYMv0pq2EyS+VevfSeVseEsT4hTAt1CWASNYbGJSyO
         LOGIPVoFi83lgkY4mgwg529nxRwvssNeRo7mvLDVC3wlJLbQ5arX2AwTt3rP+XexsxGM
         +w56V75YDMUaa6lBRvn+fYsxwb0s7U//YL2VbfOUIEiMk4mds97n8x3c24kDAA0KZU+Z
         mAEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXgqndMSU2fMdube4ywLcbHxXofVwFuKY+i3C3R8x+FtJNNJnux
	ML97n55L/Y5jyfxco7KGbj+uAQujgLIfOy3a02SjUCABo0EOx82fvhIoLnL2vwFgDnG1bUvnIA0
	ySIEStzK2TdWThjUjihsdGur7OreERfsMeFbdf5yJzpZQzFcuxWSV2jZ515m3xMN6Yw==
X-Received: by 2002:a0c:9387:: with SMTP id f7mr14512147qvf.118.1552036571099;
        Fri, 08 Mar 2019 01:16:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqz623nBVmRNZM4k4kPbHVYpGumPRvJUto9XvZzUmaVFXF67lfUQPsBneBD31ASWRTACLpdD
X-Received: by 2002:a0c:9387:: with SMTP id f7mr14512107qvf.118.1552036570114;
        Fri, 08 Mar 2019 01:16:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552036570; cv=none;
        d=google.com; s=arc-20160816;
        b=NCgFggCPTMQIb4YVDo+ha+IPkZkvhP3I593x5AvBxhS9HhdUd5bTl2ix+B7iRRi/6l
         xqKmlzLdhs5PbdwaPocO3Nep1HleQPgf3hBURIAq87fsmmA+P0POgeuhQ3i8DGUCobGs
         QYI3lYpU45sQin6TDsN7tWN1Zi8ILHgChEfQA0WUMOCbt9P9SzJmUSkeuVQZIQZnEPNQ
         uED1WRI+7qGBiGUuf1pkoFqiOtlDlCMJ5m9ZEmFMK0rMy3Z++iDqfo9qZk8nLSR+8Muq
         vVfNMedrqs1hf7ZeLqz+jZzRzm/ptfQZxK1lRvntKdDB5WAN7FWSkNIGjRi4IdJjRgZ7
         h+zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AKLLDxfHKqFNNXyshRcVxMgpIFN0qim6aujHLqnxi/0=;
        b=RBtg6dzxA569j7hAA+9yR5aF3Zut4vxnkUWLUudzWmO5hQScyBA7n2U4uzXkNWsEv8
         1cu+9cjDICnjmEVfq2WXJ2H+4ktZnjdwG7yshOUWfG47tgXnqmBDqbmTrvqyo5WGuqz+
         7ErXYuLyJlvrW7VqUi0OE7SEqN/pcmozn68oCf9TQbx6lAsLqTvfWckEXMIt19qbMQZD
         hR+B/8p1n6V+g50kNKVCWv6RC3tTCVYN4tX63UWzvf+68Qp/oHPkm/v522yqkAZc95G5
         E9rVsiMk2LpbLo0Ro9QjloNRk3JVYb+/NyKr9HEu+OCgdIlGH4hWYY4eAZd0vtPPdNqy
         w2Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si2056129qts.67.2019.03.08.01.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 01:16:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4C0C281E19;
	Fri,  8 Mar 2019 09:16:09 +0000 (UTC)
Received: from [10.72.12.27] (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AC92F5D9D4;
	Fri,  8 Mar 2019 09:16:01 +0000 (UTC)
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
 <20190307211506-mutt-send-email-mst@kernel.org>
 <20190308025539.GA5562@redhat.com>
 <20190307221549-mutt-send-email-mst@kernel.org>
 <20190308034053.GB5562@redhat.com>
 <20190307224143-mutt-send-email-mst@kernel.org>
 <20190308034540.GC5562@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <91263ee5-cc81-d2ee-b68d-828987ca86f7@redhat.com>
Date: Fri, 8 Mar 2019 17:15:59 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308034540.GC5562@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 08 Mar 2019 09:16:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 上午11:45, Jerome Glisse wrote:
> On Thu, Mar 07, 2019 at 10:43:12PM -0500, Michael S. Tsirkin wrote:
>> On Thu, Mar 07, 2019 at 10:40:53PM -0500, Jerome Glisse wrote:
>>> On Thu, Mar 07, 2019 at 10:16:00PM -0500, Michael S. Tsirkin wrote:
>>>> On Thu, Mar 07, 2019 at 09:55:39PM -0500, Jerome Glisse wrote:
>>>>> On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
>>>>>> On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
>>>>>>>> It's because of all these issues that I preferred just accessing
>>>>>>>> userspace memory and handling faults. Unfortunately there does not
>>>>>>>> appear to exist an API that whitelists a specific driver along the lines
>>>>>>>> of "I checked this code for speculative info leaks, don't add barriers
>>>>>>>> on data path please".
>>>>>>> Maybe it would be better to explore adding such helper then remapping
>>>>>>> page into kernel address space ?
>>>>>> I explored it a bit (see e.g. thread around: "__get_user slower than
>>>>>> get_user") and I can tell you it's not trivial given the issue is around
>>>>>> security.  So in practice it does not seem fair to keep a significant
>>>>>> optimization out of kernel because *maybe* we can do it differently even
>>>>>> better :)
>>>>> Maybe a slightly different approach between this patchset and other
>>>>> copy user API would work here. What you want really is something like
>>>>> a temporary mlock on a range of memory so that it is safe for the
>>>>> kernel to access range of userspace virtual address ie page are
>>>>> present and with proper permission hence there can be no page fault
>>>>> while you are accessing thing from kernel context.
>>>>>
>>>>> So you can have like a range structure and mmu notifier. When you
>>>>> lock the range you block mmu notifier to allow your code to work on
>>>>> the userspace VA safely. Once you are done you unlock and let the
>>>>> mmu notifier go on. It is pretty much exactly this patchset except
>>>>> that you remove all the kernel vmap code. A nice thing about that
>>>>> is that you do not need to worry about calling set page dirty it
>>>>> will already be handle by the userspace VA pte. It also use less
>>>>> memory than when you have kernel vmap.
>>>>>
>>>>> This idea might be defeated by security feature where the kernel is
>>>>> running in its own address space without the userspace address
>>>>> space present.
>>>> Like smap?
>>> Yes like smap but also other newer changes, with similar effect, since
>>> the spectre drama.
>>>
>>> Cheers,
>>> Jérôme
>> Sorry do you mean meltdown and kpti?
> Yes all that and similar thing. I do not have the full list in my head.
>
> Cheers,
> Jérôme


Yes, address space of kernel its own is the main motivation of using 
vmap here.

Thanks

