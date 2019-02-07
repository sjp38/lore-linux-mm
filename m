Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA068C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FF2C2073F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:32:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FF2C2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BDCD8E003C; Thu,  7 Feb 2019 10:32:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26E8C8E0002; Thu,  7 Feb 2019 10:32:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 136DB8E003C; Thu,  7 Feb 2019 10:32:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB0338E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:32:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so99747edb.5
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:32:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sHS73fT7gDED7zwubBdWP6QytBCZwH2BOh4WrkCJT0Q=;
        b=JzqzvHSUgITvxgxI4S4ugtRPhEJ4+rB9LZSzESQqxrvklICNKrTbaVMCcsipP8Ny/e
         YjGwzFmqpR5AI89jYxZDtpeWTJz2d6DBgjsVvsm57GvgGdPGeJfWtEFeDVJbVxwfYiNH
         eJb3ANc1yNxFBnydu1FnDs5VoSy/6lFpQ+6Xxyg3nIY7ftdgEPwaLlI+xUe/7OqsRhcV
         v2K3u8iGRAaPw5LOBb+15oIXhkBkfp/6ob8VeauanRgjoWS3+v/ZWYh133Ga1jtfBLCW
         3Cu+7AU62F20PG/xzwFx+I6TjNW66ttHRrhRxfKSPQd2GTMQtKPrhoAOGw1oaqYoUWNL
         6Atg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAuaKBpwWl8bPaVeQWBh1Xe44GaZ5Pkqxg9mS+6Oo59PXhf/jB9eZ
	Fo5u+u4TxGPKw8NBvHSwR7grLr6FJyThBSvqmDn99A33hDI7Xgyohxtp9zA0yixffMafDWknzsX
	ZOYibkU/wW03o3UltdM/drKYcnMuwTbv7Zv0pMvglX9DYkGtV1Dj7jO9RuZbve4wHaA==
X-Received: by 2002:a50:92e7:: with SMTP id l36mr12873801eda.182.1549553578189;
        Thu, 07 Feb 2019 07:32:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYBM+B4+ZWyiL5ahgZwhpBpJ7MYzkJKLmWqi6IsV/lYhxw0vhb6GrGwZNj6fIF8L/DW9NU/
X-Received: by 2002:a50:92e7:: with SMTP id l36mr12873745eda.182.1549553577270;
        Thu, 07 Feb 2019 07:32:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549553577; cv=none;
        d=google.com; s=arc-20160816;
        b=RoXhpFw2EWcQTMxRGqyrJSTA0VDAnPw2DuSQqFIv7R4lpyN489MNLCmbOJPLqXr13E
         G0OgIU4fmLYA6scxAyulsuZ7I3umIgTH5p9OBVqPZSnNP9LOmSH7ltnXGVkfUwFzXyrO
         lTtYZPPEC9A/T7C07NnyoiuT1J1EbdingJiqXuNKr22wRlxXSnWQY79NTF/sM0rPgE7m
         IJLNkJyHtdgnT2yHZonuRpNgydhV0CH8iVO3fe7uzXYvLT+3+PHujOj528qFLitE1tF7
         LEb70CwNvlsLY0yZr4ynBgEl7CI4hhVBzwfppcLyVaoukzAKHVl/J2krnabCjLOd0yeP
         esIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=sHS73fT7gDED7zwubBdWP6QytBCZwH2BOh4WrkCJT0Q=;
        b=VgZDEfgSOFJoGo5jMkyi3zKA2K0e1prZxB+JPGc3qZXgPhRnFGGba6rnsGShi4s960
         ao41JYWSJ/RewFZd3dNOxWzGUksCTRK3Ya9rwbBqKLp4aNSfKlg2x9fQFRB9rZ3Pt656
         +NEBP0tI8+dJWl25OomzUueJXwrSm6vv54T69G1Naq0U8NuRSPJDpSRWMoTZeFVXMMYt
         ZhFFMPmu0u0Hv8auDmPOUg2BYEl0u7IB5iz4oUrriAv2aaV3yQttUoh/PnCDB3EelYoT
         KYRjF98HkgyE4fQT91kiZsb10GtF6dBA9uPlF9xSOmhMntuk88XbcH+0ZiKaNKZDWCX9
         tX8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w6si4474587edh.16.2019.02.07.07.32.56
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 07:32:57 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 354F9A78;
	Thu,  7 Feb 2019 07:32:56 -0800 (PST)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EC90F3F719;
	Thu,  7 Feb 2019 07:32:54 -0800 (PST)
Subject: Re: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org, rafael@kernel.org, mhocko@kernel.org,
 akpm@linux-foundation.org
References: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
 <20190207133620.a4vg2xqphsloke6i@d104.suse.de>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <7bf25a0f-766e-7924-9a54-64cef9f53b57@arm.com>
Date: Thu, 7 Feb 2019 15:32:53 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190207133620.a4vg2xqphsloke6i@d104.suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/02/2019 13:36, Oscar Salvador wrote:
> On Wed, Feb 06, 2019 at 05:03:53PM +0000, Robin Murphy wrote:
>> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
>> but being able to exercise the (arguably trickier) hot-remove path would
>> be even more useful. Extend the feature to allow removal of offline
>> sections to be triggered manually to aid development.
>>
>> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
>> ---
>>
>> This is inspired by a previous proposal[1], but in coming up with a
>> more robust interface I ended up rewriting the whole thing from
>> scratch. The lack of documentation is semi-deliberate, since I don't
>> like the idea of anyone actually relying on this interface as ABI, but
>> as a handy tool it felt useful enough to be worth sharing :)
> 
> Hi Robin,
> 
> I think this might come in handy, especially when trying to test hot-remove
> on arch's that do not have any means to hot-remove memory, or even on virtual
> platforms that do not have yet support for hot-remove depending on the platform,
> like qemu/arm64.
> 
> 
> I could have used this while testing hot-remove on other archs for [1]
> 
>>
>> Robin.
>>
>> [1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/
>>
> 
>> +	if (mem->state != MEM_OFFLINE)
>> +		return -EBUSY;
> 
> We do have the helper "is_memblock_offlined()", although it is only used in one place now.
> So, I would rather use it here as well.

Ooh, if I'd actually noticed that that helper existed, I would indeed 
have used it - fixed.

>> +
>> +	ret = lock_device_hotplug_sysfs();
>> +	if (ret)
>> +		return ret;
>> +
>> +	if (device_remove_file_self(dev, attr)) {
>> +		__remove_memory(pfn_to_nid(start_pfn), PFN_PHYS(start_pfn),
>> +				MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> 
> Sorry, I am not into sysfs inners, but I thought that:
> device_del::device_remove_attrs::device_remove_groups::sysfs_remove_groups
> would be enough to remove the dev attributes.
> I guess in this case that is not enough, could you explain why?

As I found out the hard way, since the "remove" attribute itself belongs 
to the device being removed, the standard device teardown callchain 
would end up trying to remove the file from its own method, which 
results in deadlock. Fortunately, the PCI sysfs code has a similar 
"remove" attribute which showed me how it should be handled - following 
the kerneldoc breadcrumb trail to kernfs_remove_self() hopefully 
explains it more completely.

Thanks,
Robin.

> 
> 
> [1] https://patchwork.kernel.org/patch/10775339/
> 

