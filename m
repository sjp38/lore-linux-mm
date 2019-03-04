Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE97FC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 23:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EBE020663
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 23:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fwlOmLl0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EBE020663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B3B28E0003; Mon,  4 Mar 2019 18:36:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B118E0001; Mon,  4 Mar 2019 18:36:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E21658E0003; Mon,  4 Mar 2019 18:36:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB958E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 18:36:05 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q15so6470805pgv.22
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 15:36:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=LUypKyWAgSGyWeHvdhOBpuLWhC2w577ik03jidPipkE=;
        b=BUkqGuCreYp1KVedCrCZhXtoSlIsKGQQ4To5wVFJ2klZpeGFwaEzcmfHUvNMtlmv3h
         I91Tn7Br1vTpkIlqwLJgcbYYLOZXI9fXBKbUzzzCOU5Te94GoCdkUNwuy3CNJGVqorEq
         GMqDI2oq3e6APrn6Kdl9aTjbPjMq0IH1/RuNA5NXfYy4U+/4SQAMnGM4a4M5nNfZ/bBL
         2c7PYrDPfrGO4m/p/Ww7VrYNPhsHbsO2B7Y5FLxagLwrQ1HUkfIIUmNljHh2yo06yvqE
         INPwXMpem2Zli6bVU+uZQ79OGaqDNX7ovEKpf7r3I523R0uU9Z22u8rIWVIEX32PUsu7
         k8bA==
X-Gm-Message-State: APjAAAWl4p7ykwh3w9VGI3IzSk64imr9RH2lRBwWoecAMUcEdDaSiUCM
	cZPzWFFnY4Xk4v3YMFreZaBfCvRgks568uuUz1vA9IKIsR4OvnTXj4C7diS5Peh5A09/7ag9xvG
	CA8CxwrdRTzhfZ12KcwHg86sU0kj9yFdhB0X7eUaDrXkKdp94S+pkrUUGvi71XHZPbA==
X-Received: by 2002:a17:902:9306:: with SMTP id bc6mr22540517plb.59.1551742565114;
        Mon, 04 Mar 2019 15:36:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqwdpyZ9Wur3dwtJbfFbeeeoPOJKcrQNCdH7Q50PfpXD65mnwCiGKFxWoOOl1eA+EH43CUqW
X-Received: by 2002:a17:902:9306:: with SMTP id bc6mr22540441plb.59.1551742564035;
        Mon, 04 Mar 2019 15:36:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551742564; cv=none;
        d=google.com; s=arc-20160816;
        b=pV/o7P3F+z1qnQr/P0CykdbOni8TN7ycj3cY2VbBDuhdMw3dAB2mTgiFtZccGXi0ea
         QMpu7W/BRMwsQMchsdLO1NjxYOEGU7DQBpMVaB9rWSeW5pQ2h8nf94NH1/5viGLui2s/
         QZNXMIc/jd0YFWHBM5W7ioUNugJnjrIKQx5yhYOA7AYPSx1LgXo60CWe6NO51PntpF/v
         L/2t8Nq9DZoxkpMyixQpA4pKRGU22r2vr74BFrW2cds2D+3R0+4JLe2KJ91uqTksL9Yy
         d7LwC5yiIw12A5pdZPT+ecKP8Xewn3t9RDyW632h0x59iE8pJJR53rkZOJhPdd7gtBER
         qhDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=LUypKyWAgSGyWeHvdhOBpuLWhC2w577ik03jidPipkE=;
        b=zcI8+uRv320XDkakN7obJZsE3Mpp1prYLP6yiuKrOa8Ruk3y5QTFnIU6NkvcDliwZA
         a4mWcUEl3gz/V6bPmVChW2MwjwKdOUjrMK+nOV/JxlHYJPE1cRfZqnsgVR9ZXH4rsch/
         O4xztxSq3v5FG2I3ixPkwIYBVuYsbpr6GOOQu1xYgb6bR6/wvuxm6c+C097Ba0ZqcCX7
         xKZpNrE1IB6wpQRuSdtZ+AR93Z0RJ+S0ZGcPeTcO+2noPfTp7wsblmReG4Ro5QTsUrm8
         vNqXUaIR1qb8co3dwbmOmtCKMQW1e3lVvkPdXf3B+4TRau4GymvTVI11RH1+qzQ+ODfI
         9i3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fwlOmLl0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id cg1si7396785plb.124.2019.03.04.15.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 15:36:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fwlOmLl0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7db65b0003>; Mon, 04 Mar 2019 15:35:56 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 04 Mar 2019 15:36:03 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 04 Mar 2019 15:36:03 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 4 Mar
 2019 23:36:03 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
From: John Hubbard <jhubbard@nvidia.com>
To: Ira Weiny <ira.weiny@intel.com>, Artemy Kovalyov <artemyko@mellanox.com>
CC: "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford
	<dledford@redhat.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
 <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f73f326b-1ef3-075a-ca11-88d0d881dacb@nvidia.com>
Date: Mon, 4 Mar 2019 15:36:02 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551742556; bh=LUypKyWAgSGyWeHvdhOBpuLWhC2w577ik03jidPipkE=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fwlOmLl0bA1eSZQSHtrtyySK3uXtyYQNojUOe98wUXJuDL0XQXYZx5dI+BUXIkkUE
	 io0h06ZVgQ5wgEDK7p+XIJVPQ6G/OwNmqo269Ob8b2+kDDwCuMuYABBIPrgB1eDcCW
	 vyTLErz7dXLyE93JSquox3by49k4sUg+OU+6bBagQBO1ie7qJnaz8BpNitzoZT0b6b
	 nU9IHAf19k8bqcdaQjDFYmDAvK978fFxrzopTxp2LSk9NIQQGiI5bgR61Mtirmfi1I
	 hlB5MC1721tALbWwhAe2ZP8NFT6SjUD8/Ysnez4F/7IA8uatSL40zNlLMB2vVfGEHp
	 vkqcqkjgAYRbw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/4/19 3:11 PM, John Hubbard wrote:
> On 3/3/19 8:55 AM, Ira Weiny wrote:
>> On Sun, Mar 03, 2019 at 11:52:41AM +0200, Artemy Kovalyov wrote:
>>>
>>>
>>> On 02/03/2019 21:44, Ira Weiny wrote:
>>>>
>>>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>>
>>>>> ...
>>>>> 3. Dead code removal: the check for (user_virt & ~page_mask)
>>>>> is checking for a condition that can never happen,
>>>>> because earlier:
>>>>>
>>>>>      user_virt = user_virt & page_mask;
>>>>>
>>>>> ...so, remove that entire phrase.
>>>>>
>>>>>   		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
>>>>>   		mutex_lock(&umem_odp->umem_mutex);
>>>>>   		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
>>>>> -			if (user_virt & ~page_mask) {
>>>>> -				p += PAGE_SIZE;
>>>>> -				if (page_to_phys(local_page_list[j]) != p) {
>>>>> -					ret = -EFAULT;
>>>>> -					break;
>>>>> -				}
>>>>> -				put_page(local_page_list[j]);
>>>>> -				continue;
>>>>> -			}
>>>>> -
>>>>
>>>> I think this is trying to account for compound pages. (ie page_mask could
>>>> represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
>>>> But putting the page in that case seems to be the wrong thing to do?
>>>>
>>>> Yes this was added by Artemy[1] now cc'ed.
>>>
>>> Right, this is for huge pages, please keep it.
>>> put_page() needed to decrement refcount of the head page.
>>
>> You mean decrement the refcount of the _non_-head pages?
>>
>> Ira
>>
> 
> Actually, I'm sure Artemy means head page, because put_page() always
> operates on the head page. 
> 
> And this reminds me that I have a problem to solve nearby: get_user_pages
> on huge pages increments the page->_refcount *for each tail page* as well.
> That's a minor problem for my put_user_page() 
> patchset, because my approach so far assumed that I could just change us
> over to:
> 
> get_user_page(): increments page->_refcount by a large amount (1024)
> 
> put_user_page(): decrements page->_refcount by a large amount (1024)
> 
> ...and just stop doing the odd (to me) technique of incrementing once for
> each tail page. I cannot see any reason why that's actually required, as
> opposed to just "raise the page->_refcount enough to avoid losing the head
> page too soon".
> 
> However, it may be tricky to do this in one pass. Probably at first, I'll have
> to do this horrible thing approach:
> 
> get_user_page(): increments page->_refcount by a large amount (1024)
> 
> put_user_page(): decrements page->_refcount by a large amount (1024) MULTIPLIED
>                  by the number of tail pages. argghhh that's ugly.
> 

I see that this is still not stated quite right.

...to clarify, I mean to leave the existing behavior alone. So it would be
the call sites (not put_user_page as the above says) that would be doing all
that decrementing. The call sites know how many decrements are appropriate.

Unless someone thinks of a clever way to clean this up in one shot. I'm not
really seeing any way.

thanks,
-- 
John Hubbard
NVIDIA

