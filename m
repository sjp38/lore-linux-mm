Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A625CC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55F6220896
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="vqXpLsAU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55F6220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C746B6B0003; Mon, 25 Mar 2019 12:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFA6C6B0006; Mon, 25 Mar 2019 12:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2F46B0007; Mon, 25 Mar 2019 12:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E33F6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:59:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d15so9872489pgt.14
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:59:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=NWGLIQGu38/jJb6e8uWtmgESprJGVMgumpIJ57GgwLQ=;
        b=TA8XogRhw4+8NqJ1Ub1MgxDJTRcjyePRKeo2+zN5uUqT3klWt+L3z/UUNXPY4sEPMs
         lZCus8M2RUbsUXaFcs5f4GxUGiZXlKJle8S5rx4RX8pEgf4IJoNGw7VkEhXdamF+G7s5
         ykdJQ0rqe1OxtoACW/pHA3qKfsybO3o2NmTwJJaLKwJaTVR2di8fOY4OKnh9ji4MDZcp
         eWs2bD5gCL582U1u1UyGhVB6uqV5VEpWH4g1gaFHjA5pcmz82pHTn5LCkRHD16qjE/qJ
         6hkm8u2xLqiZoaCu4W072nQwjgLSIJs0uTQ3tvB3ya9umWphqRkxmN+z0+BeV35/va5F
         3aTw==
X-Gm-Message-State: APjAAAWCCrDBzFKFszxw4lAhAXRxjOhSAh6mYsoIWFvSqkal4YTnQo+K
	d+Oa0pnESY4dp6Fin+2whSuydr2tEGONcfWz5zFDiAcc6kW0VEbtJEZjc6OQtYnsBxaYT5ijvYl
	q5d5Aq8NllYJcnHb++m3Tqf9gPrm9mzhyekM7yHYWDaGp0M1uTNR6BsZ7z1PPzOnpcA==
X-Received: by 2002:a17:902:a9c8:: with SMTP id b8mr26378371plr.12.1553533174011;
        Mon, 25 Mar 2019 09:59:34 -0700 (PDT)
X-Received: by 2002:a17:902:a9c8:: with SMTP id b8mr26378311plr.12.1553533173344;
        Mon, 25 Mar 2019 09:59:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553533173; cv=none;
        d=google.com; s=arc-20160816;
        b=eoA9sqL9sZRtETk7XCm1hEma7nZ+35Eg1KsW/nHgYVUROzxI1Do3cmGEg0H5YZc9I4
         fzoWiKVIqyFC8tHx8L0RYGOZ69VDUi80sig+cmq9To8gBeSA56lWPGA6LXmpMASuWYpP
         txZ7pgllJb68mkN+s9cNEc4MpuIuqCRUYzct9SOlHLdjuiNk/W/pEUbrP2akIrNjZJX6
         sMjEyRH3JViOYIxKTrlKhDF1D9PUcr2i2DS4dtRdIvvEum+vjMIJ90PK/DehkkRSXM64
         ST1ti+B2nEj1A9D/rMLhdAl0kJ2c6wlqVoAHSABAemIleXo1Vsijp9IMmTbmDTiGYhgz
         zWaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=NWGLIQGu38/jJb6e8uWtmgESprJGVMgumpIJ57GgwLQ=;
        b=YF4GLn4czdYkz853Ln+m03mOhQ5EtCoLxC30D/QYPm6hCWhjgALGpfOOQ1QvBDV7H+
         9/NWBdFhEQ+PvlAi+kpk7oDypXPFDRmGJzDP8I8cNaW1K8H/tsfpMpgcXix1KJlrCE8/
         QLv+QLhPNVPM+BwBOxKVpqOyp1LJoVygeY7QdhT00YGXHlLdFTP4x9PS+n1uq3rvNQuU
         Wcqx9WPdK8hruNQMc1Ap9L+/3V/BtnUO+YReV3UaVFARoOLhD9lJQhymvJFxjiWpyvh/
         eqzkhdQqyMFX3T2ySiZwaNGLe/1fuuqjBaa/rd72bvr8fEhcE3EypsoT75b8d4JO8yOS
         ik1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=vqXpLsAU;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor10685185plg.60.2019.03.25.09.59.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 09:59:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=vqXpLsAU;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=NWGLIQGu38/jJb6e8uWtmgESprJGVMgumpIJ57GgwLQ=;
        b=vqXpLsAUGm0QT70kX4qwhbmciXz3cS7QYuXaQZf1e26ddA9ixDkoyH1skKslX3iVK9
         U+yWZOWSgHV8bhdUFn28dzhI/SwxuP/uPdlwilQ8Zwe4VEmI0WKVyP9IAhi8pyL04eTI
         bTJXctHM6c0Kf0OAEgUhwGhw9urE1YlnLPivsY8jyT0xz0LWVR1FrqmKWJdNuavaFM/7
         u/IQl743Qcbo6PgvrV7mgBYltaw80uUEbBty85iiwU0UL5oyh2cl6M7+Lx8F3nAPbBRP
         fO3QZ1DMn+N9myfUKaXFcCqzdlt0Xx7FTgpWGy7xyJ+eLzsmAESdOMRH2cttOuq0QPXZ
         wSZg==
X-Google-Smtp-Source: APXvYqwXslOnXOKe7wC30klcY2KN8K5xcX4jq5xguuZL/3Igbc5bGQNlXFr+P0grfxvTw8OCG3cGEA==
X-Received: by 2002:a17:902:e684:: with SMTP id cn4mr3383014plb.71.1553533172882;
        Mon, 25 Mar 2019 09:59:32 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:0:1000:1612:b4fb:6752:f21f:3502])
        by smtp.googlemail.com with ESMTPSA id z77sm30426023pfi.155.2019.03.25.09.59.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:59:32 -0700 (PDT)
Subject: Re: [RFC PATCH] mm: readahead: add readahead_shift into backing
 device
To: Fengguang Wu <fengguang.wu@intel.com>, Martin Liu <liumartin@google.com>
Cc: akpm@linux-foundation.org, axboe@kernel.dk, dchinner@redhat.com,
 jenhaochen@google.com, salyzyn@google.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
References: <20190322154610.164564-1-liumartin@google.com>
 <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <9b194e61-f2d0-82cb-30ac-95afb493b894@android.com>
Date: Mon, 25 Mar 2019 09:59:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/25/2019 05:16 AM, Fengguang Wu wrote:
> Martin,
>
> On Fri, Mar 22, 2019 at 11:46:11PM +0800, Martin Liu wrote:
>> As the discussion https://lore.kernel.org/patchwork/patch/334982/
>> We know an open file's ra_pages might run out of sync from
>> bdi.ra_pages since sequential, random or error read. Current design
>> is we have to ask users to reopen the file or use fdavise system
>> call to get it sync. However, we might have some cases to change
>> system wide file ra_pages to enhance system performance such as
>> enhance the boot time by increasing the ra_pages or decrease it to
>
> Do you have examples that some distro making use of larger ra_pages
> for boot time optimization?

Android (if you are willing to squint and look at android-common AOSP 
kernels as a Distro).

>
> Suppose N read streams with equal read speed. The thrash-free memory
> requirement would be (N * 2 * ra_pages).
>
> If N=1000 and ra_pages=1MB, it'd require 2GB memory. Which looks
> affordable in mainstream servers.
That is 50% of the memory on a high end Android device ...
>
> Sorry but it sounds like introducing an unnecessarily twisted new
> interface. I'm afraid it fixes the pain for 0.001% users while
> bringing more puzzle to the majority others.
 >2B Android devices on the planet is 0.001%?

I am not defending the proposed interface though, if there is something 
better that can be used, then looking into:
>
> Then let fadvise() and shrink_readahead_size_eio() adjust that
> per-file ra_pages_shift.
Sounds like this would require a lot from init to globally audit and 
reduce the read-ahead for all open files?

Sincerely -- Mark Salyzyn

