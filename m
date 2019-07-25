Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BB20C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:42:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 590E3218D4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:42:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 590E3218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE02B6B0006; Thu, 25 Jul 2019 17:42:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D90178E0003; Thu, 25 Jul 2019 17:42:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C56A08E0002; Thu, 25 Jul 2019 17:42:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7767C6B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:42:20 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v14so24568737wrm.23
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:42:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RHA2ofEYLbAhfGb8SVCv0oG+oLR4u8BdgY4SBsCsRuA=;
        b=itSX/dWXpnm8Zve5Hv971T9Lrinc5CsalQRAXM8l7Zp2LpaNAbwbnrlnTEaewOJ+5C
         B68oAd0KcptN1m6cD34xq6u7wCwLMYbUEdzmvWf/q5W+cOPMx+UrcpwTY5NCuy/8+j3R
         nv8buEPmc1mLuGfvE9nO9yqdBaFokMw6hkgNey79eDS0dGN+qDNEJP+4xsNInrhkEa4s
         t6GJbsm8rE+2Aa3N8h4NQj6LEsaBreSAkmfBjrlQ5JQqHSQzlzKLXTOamjdnyzZg0j/x
         W6rSHuidBVT6oD9+ptBoyNU/BL6IsUtjHqdbLBbOzrkWj/qJkJblJQk1Fl92jTyr1LLN
         0BNQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAXChPu0bvf25+GiZslevZIEnQ6oC58ZOhjFlKZYqsLZk74YKMd8
	mFfI8S6mBDFRgW/Otaq/n5fdsABbkToN2aKQlSIF57x/a73t6rRx7unpIpsxNke3PTly+wsizqG
	Dc+n4S4K/VKoP1bb1ofDaGrQcjZVHyHnV/jjfo4KyGXLRL3c9+0AuVym9YkLtjS0=
X-Received: by 2002:a7b:c081:: with SMTP id r1mr30756907wmh.76.1564090939975;
        Thu, 25 Jul 2019 14:42:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgRF6os7PdfzkTw5rgWI8XeuP+NBdIxzuk+zrCASfHUAfAb4guTub4qo/0x+C2FRG0G1ON
X-Received: by 2002:a7b:c081:: with SMTP id r1mr30756879wmh.76.1564090939078;
        Thu, 25 Jul 2019 14:42:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564090939; cv=none;
        d=google.com; s=arc-20160816;
        b=GsZtiGfHrDSZt7UyYO07x7TunLRSUaPc+GxAzRjze93sGYzO7JaQROGhTdwyXeijIZ
         p4XeRK0LbmcO15Um074PA6i9RaZKD9AGheY1sGMtiEL4le/pWCrWiJt17ZEVxtVso3GU
         z595i5NrdFttVlj0w1mSWKXPJY0t0kvhRJhXXAP2rInbBORJZyAmHNLRJNUrjCUJhrnh
         Gx05LXKIpr5xPUHaTj2iyQqjnX5UFC3f8AS9GqWeJaXrsEUUtUKAk6sgOy2SzuHW/o1P
         ZL5BTMvtPLoCwHjuFAXqurXBsu8ZRbfXT0Cunr89THVYJWl3IvMHdnAZKtb2/3VWwjAH
         8ONg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RHA2ofEYLbAhfGb8SVCv0oG+oLR4u8BdgY4SBsCsRuA=;
        b=c2OhGm/bBibbGK6niegMwHKzWv2Xfw/7N2XaEuRda+jLyX9Cbj26BJcN/340X9BNiB
         3Rw951HSGqp4dX/Ybs3W7bycOD0tr7dESwTw01DpSRaUc6Fm58zSAjVNSU8k3i9eYAVN
         0k5VyD2wG5PmEyb2VkpKGrCZAcoasuG/YELcjtZ6kFnViNp8pxxEGARSl08nnSmeECXx
         gEFORS+Q+iBjR0cpZUuGvje73ZidoIZCYeNgHIpRfLF1jKKYv+u3FZk+eYScAAJk1ZfL
         0dQUBgaeY/uYQ1ZS4gwwBwzkmBGyZeURv1C84JQcBMmHUHg6zbEnCV+MB+qRnXfyBVkG
         sMjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id a2si49721276wrv.230.2019.07.25.14.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jul 2019 14:42:19 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 11487 invoked from network); 25 Jul 2019 23:42:18 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.6]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Thu, 25 Jul 2019 23:42:18 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
To: Chris Down <chris@chrisdown.name>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725145355.GA7347@chrisdown.name>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <06bc6218-810d-a912-935c-cb09d063ec3d@profihost.ag>
Date: Thu, 25 Jul 2019 23:42:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725145355.GA7347@chrisdown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chris,

Am 25.07.19 um 16:53 schrieb Chris Down:
> Hi Stefan,
> 
> Stefan Priebe - Profihost AG writes:
>> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>> varnish service.
>>
>> It happens that the varnish.service cgroup reaches it's MemoryHigh value
>> and stops working due to throttling.
> 
> In that kernel version, the only throttling we have is reclaim-based
> throttling (I also have a patch out to do schedule-based throttling, but
> it's not in mainline yet). If the application is slowing down, it likely
> means that we are struggling to reclaim pages.

Sounds interesting can you point me to a discussion or thread?


>> But i don't understand is that the process itself only consumes 40% of
>> it's cgroup usage.
>>
>> So the other 60% is dirty dentries and inode cache. If i issue an
>> echo 3 > /proc/sys/vm/drop_caches
>>
>> the varnish cgroup memory usage drops to the 50% of the pure process.
> 
> As a caching server, doesn't Varnish have a lot of hot inodes/dentries
> in memory? If they are hot, it's possible it's hard for us to evict them.

May be but they can't be that hot as what i would call hot. If you drop
caches the whole cgroup is only using ~ 1G extra memory even after hours.

>> I thought that the kernel would trigger automatic memory reclaim if a
>> cgroup reaches is memory high value to drop caches.
> 
> It does, that's the throttling you're seeing :-) I think more
> information is needed to work out what's going on here. For example:
> what do your kswapd counters look like?

Where do i find those?

> What does "stops working due to
> throttling" mean -- are you stuck in reclaim?

See the other mail to Michal - varnish does not respond and stack hangs
in handle_mm_fault.

I thought th kernel would drop fast the unneeded pagecache, inode and
dentries cache.

Thanks,
Stefan

