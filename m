Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D91B6C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:25:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 533D5208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:25:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="0UqRsySv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 533D5208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D996E6B0276; Tue, 28 May 2019 02:25:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D23616B0278; Tue, 28 May 2019 02:25:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC4896B027A; Tue, 28 May 2019 02:25:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52DB26B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:25:17 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id r8so3225163ljg.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:25:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K6zlxuXc3ZiiYmoECKuEjIeU1HxTh98Kh3YIPYtNrec=;
        b=IEb5iBKVI5xFCf/OywPwFrRtAPOOZf1jpBkJRaNEF5r1Qc4FYnQ/+/jMtn0NIzf46b
         vaqJd6zKdqVmFkHeIVJ0+Qa+eX7eO7PK7EjfhjKg6NV4oj7k+Db1UUB+7LssAKLXp7Bb
         bnEwcBuggW/SnBmHu8YoSkEiFzNx9gaxWtqZadJxTp6+6853jMBQHpAdRBTREKetb7UO
         Q8FpmGXIt8MTc0pcc6ct8jmDyWlRyG1pmMJIRvA06fBSGv6RwGvSeyUZD7PekmfBGBVq
         PUJe0XS07/tTqaZLK5SGGfJMsiUIu+v1v7Fq1kF7izpwP0N+Yi8/7wb5VguJsRSFhpMf
         v/4A==
X-Gm-Message-State: APjAAAUovqjwQjW2Ys9iW5RF+954OZTP2LQFFHluDpbjvhO6+vJ/Ktgk
	6HEbARbpGCOO88elVL8+mhyZXI3S3f975HV43GQV8n4IWa/3Zb0993FV4xCtrhDb7bKOKhgHaH3
	VPD74JMSUAVoYru75NKtAB/W4xH0yTeqZ1PSEMBeF9xJUZNboD9ZSAunrAd4V8Q6gtg==
X-Received: by 2002:a2e:1312:: with SMTP id 18mr15366104ljt.79.1559024716405;
        Mon, 27 May 2019 23:25:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIaLbxKUk8wzTMVACD7ca+ydaIgsX+mtQf9pc70e1M2/eOESMCDxKuHb03cxTxDgm2UdSV
X-Received: by 2002:a2e:1312:: with SMTP id 18mr15366052ljt.79.1559024715396;
        Mon, 27 May 2019 23:25:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559024715; cv=none;
        d=google.com; s=arc-20160816;
        b=J6W8gxcrlKyC7xv7THK5xVCzVeJscsAHNh+EPd7Os7AcN7A0I57zrOeHcOjA+ju1R2
         6xmJ3l7eXNwJCg3m10OlEdYC0Q2vOjf745Oq2xvA6fpxIYz1qNGxtwf68vadsqfwxhIC
         DK+6+5BNqVEPmFJCFT1XxrUPOBYB9WHmWS8YR3jegXNNqHmD527UAERHWBWs669D7Hcx
         x31QrRQMyQkwgeA3V0NeNu9Bk9SEt6zLSswLQDpGlpp3iuKPehj18ga2C97pRwr4+22E
         ewSPANFlQSGSQFxZi8QEIT5gLccmuzRyuqRpk2SKDJ4JDhBXaXM3EavAhJxTpNwmFghz
         2TsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=K6zlxuXc3ZiiYmoECKuEjIeU1HxTh98Kh3YIPYtNrec=;
        b=vtkIaobdn3qaYBVYyREAFh1ocipiFSvLr9tsDwdT21DUAO42t3epyVE1lDJ2LViaAQ
         p5G0YZbrNXEaJh//P40pMJ+c+9Wo6fXwlRTkR5zwA6GhbKefIBXEzAn5eLLQyr0XB34I
         J1zJYdrZJoIedkfjpxZFyuYawm7c4U7SR60VII3BEKJKmN03o2ArOCd8jzDeRm1Ctyuu
         55ehM8B6owfrCNTG+TdfINg+lghB6qovprCFJRcfAr2gZA90VjPQk97S6EqNCZgL5gH4
         p364p6NJE1pgOu6arDzm2hrUmP9pADPD4ijKcoxZxsfH8PKAP/hezYm1ZOLj9dZiHdwU
         dJPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=0UqRsySv;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id e21si14620577ljl.207.2019.05.27.23.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:25:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=0UqRsySv;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 697642E09A5;
	Tue, 28 May 2019 09:25:14 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id gjyj3ZqPVy-PDkmUO4v;
	Tue, 28 May 2019 09:25:14 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1559024714; bh=K6zlxuXc3ZiiYmoECKuEjIeU1HxTh98Kh3YIPYtNrec=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=0UqRsySvqkS3LazKxNnApMjZpK/fP1oYQCh/U/or4cG9kcftMas6WFNhHUnoTm/mu
	 xhatMyLM6ZE7I7HlX2it0JxbGr6r05Hd3NVN81shFwOyBHjHeocCoevZ6WNjmXGgQa
	 ppF4bsoDsM3TaIHQpkY0itz36FQqkPfJa8J7/QvI=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d877:17c:81de:6e43])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id jGMIvBUfvr-PDd4CQrV;
	Tue, 28 May 2019 09:25:13 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>,
 linux-api@vger.kernel.org
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz> <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
Date: Tue, 28 May 2019 09:25:13 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190527143926.GF1658@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.05.2019 17:39, Michal Hocko wrote:
> On Mon 27-05-19 16:21:56, Michal Hocko wrote:
>> On Mon 27-05-19 16:12:23, Michal Hocko wrote:
>>> [Cc linux-api. Please always cc this list when proposing a new user
>>>   visible api. Keeping the rest of the email intact for reference]
>>>
>>> On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
>> [...]
>>>> This implements manual kswapd-style memory reclaim initiated by userspace.
>>>> It reclaims both physical memory and cgroup pages. It works in context of
>>>> task who calls syscall madvise thus cpu time is accounted correctly.
>>
>> I do not follow. Does this mean that the madvise always reclaims from
>> the memcg the process is member of?
> 
> OK, I've had a quick look at the implementation (the semantic should be
> clear from the patch descrition btw.) and it goes all the way up the
> hierarchy and finally try to impose the same limit to the global state.
> This doesn't really make much sense to me. For few reasons.
> 
> First of all it breaks isolation where one subgroup can influence a
> different hierarchy via parent reclaim.

madvise(NULL, size, MADV_STOCKPILE) is the same as memory allocation and
freeing immediately, but without pinning memory and provoking oom.

So, there is shouldn't be any isolation or security issues.

At least probably it should be limited with portion of limit (like half)
instead of whole limit as it does now.

> 
> I also have a problem with conflating the global and memcg states. Does
> it really make any sense to have the same target to the global state
> as per-memcg? How are you supposed to use this interface to shrink a
> particular memcg or for the global situation with a proportional
> distribution to all memcgs?

For now this is out of my use cease. This could be done in userspace
with multiple daemons in different contexts and connection between them.
In this case each daemon should apply pressure only its own level.

Also kernel could remember static pressure applied from each cgroup which
fades away when memory is allocated. And each call adds this pressure to
own requests to cooperate with neighbours. But rhight I don't know how to
implement this without over-engineering. Pure userspace solution looks
much better.

> 
> There also doens't seem to be anything about security model for this
> operation. There is no capability check from a quick look. Is it really
> safe to expose such a functionality for a common user?

Yep, it seems save. This is same as memory allocation and freeing.

> 
> Last but not least, I am not really convinced that madvise is a proper
> interface. It stretches the API which is address range based and it has
> per-process implications.
> 

Well, this is silly but semantic could be explained as preparation for
memory allocation via faulting into region. But since it doesn't need
to know exact range starting address could be arbitrary.

Also we employ MADV_POPULATE which implements batched faults into range
for robust memory allocation and undo for MADV_FREE. Will publish later.

