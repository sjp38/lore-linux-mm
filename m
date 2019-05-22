Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA52DC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:09:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FF3620868
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="l/Ej5NzV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FF3620868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC7226B0007; Wed, 22 May 2019 12:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C772D6B0008; Wed, 22 May 2019 12:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B663A6B000A; Wed, 22 May 2019 12:09:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 539416B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 12:09:26 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id t77so497555lje.17
        for <linux-mm@kvack.org>; Wed, 22 May 2019 09:09:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xHyX4E1Hji0iAx9uaJym9J5zgLcAXlnGb5qLA9y3lOY=;
        b=qVZHwyQBC7aJlWpHKTXPhpFeNF1shVolBrEHUiyD5Vb5zohoooRZ1nU3WYND6cz7jQ
         6Fl21TLHymfBaJwxyXp4XBGwe+ka7xIpJF/B7268GjnFEMoTKryzTCMxpq2sLfCjdEzI
         ezeQqJkPZKLRGfT7qg9MPnNpgd5NRe3Ra6V2fNcVszPjWDhu54LPJdKGnQZVXecFksAh
         L1cwMxUfo+TyxpklsdtRVupNbmzQBxM0Vn2oSnuBuEoIsJIPgeHDcuLnvkCFxVizOufe
         8+l2JXDu+enI0KayaoSBdBBX5ScxnC8dpT3L0Ssfpyl/qAXXzkHiLysIlZYLvH58tmYg
         8mXA==
X-Gm-Message-State: APjAAAVF3rDyEiVgmQnX+Ih+gd1WbWsjUpG+7PKOlhxRpc5c3tsz3KFy
	9TlqK12/VIfYzdc8ReEfgXb0xGMvWt+787Zy6gfjHEDotg3J7ctyIvib82CvxRtx+atuXkiICO0
	0K2mxgcp9AstPSh8bMxVCr2lIf7g8XJzlYPqbaAZvPiwrxt+LoZF0MAPOiVmP+MtONQ==
X-Received: by 2002:a19:4c55:: with SMTP id z82mr36318207lfa.68.1558541365456;
        Wed, 22 May 2019 09:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh9KTbpVxKFSls7Sge3TEuilFWE5zVb6aAZXc4Dkg27byEan80DAwCkK9Ft1bWNLyP6Q3w
X-Received: by 2002:a19:4c55:: with SMTP id z82mr36318162lfa.68.1558541364624;
        Wed, 22 May 2019 09:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558541364; cv=none;
        d=google.com; s=arc-20160816;
        b=PDJGoLFtZ2ovmtcRRNT8rfwyj7Ba0n5c5evPMybhvsQhpr9YpWa672uwBo2gdhF4GB
         Nh3FfVFvWPx7kD3DVWVH2+DwGB+Lf5f0QJuOfNXLT05C4pSZ+evjhXq3HYdMZdN5dQos
         3RkP1r6Zd450IwMtTUmy5lJbvy1N/kzTb9CdwzfG4piDPYVIAj1BZVLl0jC6Eejf4mNi
         DlmihUrtDY9plOU/NXf3sjnYlFxR0UWRh+2bWetqc17qYMHvKL0461diSNZc9Ub7wciF
         fPEgS08E3hlbmaIIGcWHNrN5TQ0jkVm4I1bopUII/BoUaxe5AKKg30sdrbbqFBjk3khi
         MU0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=xHyX4E1Hji0iAx9uaJym9J5zgLcAXlnGb5qLA9y3lOY=;
        b=xlpDnGKjZRrqPHqxImQIawk0fwJZJbQdf+k4B5RSsxC27+p6rzZ3rs9SP9KTaDN/Bf
         rqCTCynzecRLVMQrBY56r1Z5M8ycdadgI4iM9Lw844y9WEPebpO3+d29jYKtnXr5KoMe
         9jL+kj869Ekmr6vH5zo27laVTa2IY6+hSdJ0LhVdCJP1SP82FoaQ1SeOqMSzRgxYkDc7
         jYcSREWPhs+e2spQ3GVtxcVdL95a8JrWWbNmWu9/2IS30GTzf4YMGV6NCQMW8m6Sn2pk
         4uPY6zBAx+O0nEAsmyL53IV5we5y7e0oeTyMiEI6OHOM7TKFvKg4khbA8jVmQbEgf1dv
         vCFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="l/Ej5NzV";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id s22si22294443ljh.180.2019.05.22.09.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 09:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="l/Ej5NzV";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id DB0422E14B1;
	Wed, 22 May 2019 19:09:23 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id c8metHw3vh-9Np8KpjV;
	Wed, 22 May 2019 19:09:23 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1558541363; bh=xHyX4E1Hji0iAx9uaJym9J5zgLcAXlnGb5qLA9y3lOY=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=l/Ej5NzVQcufOB3jmlM+euSF3y40LxiUq3TRKaX8JoZx4OfqfO44542FgflQDfSwc
	 IMOjz9cFfrQ9s8hvjkfGWJOETXbTRWmJXsb45BibDM62/X3VNsxQAkyZ3sQhLaTdW+
	 6GBNP2BcT6L5Jz8gLr38rpDz8CbWPJBJSULfWWlA=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:e47f:4b1d:b053:2762])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 6jbXv3Q5sw-9MdqBFAT;
	Wed, 22 May 2019 19:09:23 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH] proc/meminfo: add MemKernel counter
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
References: <155853600919.381.8172097084053782598.stgit@buzz>
 <20190522155220.GB4374@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <177f56cd-6e10-4d2e-7a3e-23276222ba19@yandex-team.ru>
Date: Wed, 22 May 2019 19:09:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190522155220.GB4374@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.05.2019 18:52, Michal Hocko wrote:
> On Wed 22-05-19 17:40:09, Konstantin Khlebnikov wrote:
>> Some kinds of kernel allocations are not accounted or not show in meminfo.
>> For example vmalloc allocations are tracked but overall size is not shown
>> for performance reasons. There is no information about network buffers.
>>
>> In most cases detailed statistics is not required. At first place we need
>> information about overall kernel memory usage regardless of its structure.
>>
>> This patch estimates kernel memory usage by subtracting known sizes of
>> free, anonymous, hugetlb and caches from total memory size: MemKernel =
>> MemTotal - MemFree - Buffers - Cached - SwapCached - AnonPages - Hugetlb.
> 
> Why do we need to export something that can be calculated in the
> userspace trivially? Also is this really something the number really
> meaningful? Say you have a driver that exports memory to the userspace
> via mmap but that memory is not accounted. Is this really a kernel
> memory?
> 

It may be trivial right now but not fixed.
Adding new kinds of memory may change this definition.
For example hypothetical 'GPU buffers' may be handled as 'userspace' memory.

