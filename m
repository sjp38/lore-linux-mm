Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3BCCC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 787D020883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:30:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="DeNEc67D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 787D020883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16916B0270; Tue, 28 May 2019 03:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC62A6B0273; Tue, 28 May 2019 03:30:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40076B0275; Tue, 28 May 2019 03:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 718256B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:30:16 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id l26so3247255lfk.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:30:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=b0tnBEaeSE0wx9SZBTkiemsceGG2gh/BPri5iBFlmTM=;
        b=a/AxzepUTbEzdCPW4yRZXsd+repG7BmBnUSVb/5R733mqr/3LvZna+exyJ1WpyriF/
         /+N/WALpbkFnEHqtzn8t8HaJZsJouux+XBiR0D7zyo1/6Z3SZtsU+WcOhn8LyLgaMJzJ
         0oyQMijRC/XRbYM6C3F8ryOJQgkGzcW0+63FK9bSMk7IUYmaPH6Ze+MkQmfS795QkRNU
         GBLxppEewCX61+1DTzaFLcgHn4e72D2DXVYaNEeQWY4+N6ZwCCyHsszl7s1JTIBitHe0
         hHv638ACXsEAKVa4FTAVzqXJe5w/sWWIREvMZIfYzPumtwBommvXVXu+hq+ptir7zWkX
         pw2g==
X-Gm-Message-State: APjAAAVuHTBzDDEeuZ+W2r972g+NzTg+iU5vO93usUH+dpyFx6v2ULLS
	OvynZ6NZWSIY0bzF4boBqyTGCUys0UdeSvluRdMfeyDXtQ2qRbUFwnv4V4qD4RT83zrMU5fBmz0
	qU3xoe3MJNb3ynMSe228uiDx9wNBwAdi3CvWRzkiccL+0U509Pan74BWYgBszqxKGYA==
X-Received: by 2002:a2e:970e:: with SMTP id r14mr15359786lji.86.1559028615612;
        Tue, 28 May 2019 00:30:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/C4yXQ1FUgwzohXpPg23V9vDZT20LBYtC+IKnFx5A3I1rJi4RCyya9pF38P84xnOZF2FB
X-Received: by 2002:a2e:970e:: with SMTP id r14mr15359725lji.86.1559028614576;
        Tue, 28 May 2019 00:30:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559028614; cv=none;
        d=google.com; s=arc-20160816;
        b=YkFRT6rszsWvNCXTWSE/jBxw+htpAjXVzevAsRCSzDR1cyEa8md3a2PFrWKqXJ1GLQ
         Z6XzaxEBa4t/8udHGf+2L3ziYXNZZCs/WbzVKvEujw9C6pFAW09KW7UC6F28pbYky5I1
         4qvyB4rlw5TVT9/vESBrk/XXNxNjoXVOlnWenF0Lq3q+fpm3ePxCfYaa/VcgJ+4CJtpp
         qODTMJk5s21ZiPVeJwXSF6MghBtiRp/xTsMjI/caCdfdWmhCfDrXZ7IRexwkuQPxxqu0
         OFqo9zEUUDM3IHy/Zq6z+fD52Udv2SQSqK9kO8GC9EZi8z81X4JulTE9dbM92lBmkIRe
         I6xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=b0tnBEaeSE0wx9SZBTkiemsceGG2gh/BPri5iBFlmTM=;
        b=uUFjL6gGptABP6ty7uLOVm9gD7moiJUx2CVQXdJnIUK4cBpEbJ2EDMox4XRlCNzbR4
         9Os6Uvgfb22KZV22/6oZ0BdKR6AInEuCIRBUcBMEW2fTej1J9UO2bYpxq4re8+yVuMZ/
         AmX6hCMcfqu1O5a/XxVS0sKxGJyWYYT5HKlSYET7AfQZDtEo+4OVT6astv5oqVtIk7Bn
         fi6iiK9nXG0KwxWYdP8DZS5pr10pO8pkGxcBPbvri7zJJOfUO5HkX2ztP4QSZCAUm4/r
         H7k0pJAJ8sOW/LqU5qCKcVL2d/4/8p8ANpZdxvflD7A2ci6sBmD5xy96AqZ5GZWuTbNe
         zxvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=DeNEc67D;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id d3si11602518lfc.65.2019.05.28.00.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 00:30:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=DeNEc67D;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 9F0C32E1491;
	Tue, 28 May 2019 10:30:13 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id WmZsxO0Rsv-UCpWmw9d;
	Tue, 28 May 2019 10:30:13 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1559028613; bh=b0tnBEaeSE0wx9SZBTkiemsceGG2gh/BPri5iBFlmTM=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=DeNEc67DccTvfjrv2GfpuCVW+0gZXFHC6VH0rBG93Qz6lpTLSEf0QDCDa+3WL7I+X
	 GZ8AN9RY+GikIyHi0zKEkYkJ7LcVcPAMrKYVVVMk3GQ1tgfpYnF2u0AnUQXSJ9zY2x
	 SaDK7qu1acKd2GlSFahxObLpKxDazFH1JAOnVFfc=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d877:17c:81de:6e43])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id bD1sDRHzsZ-UClmLKBl;
	Tue, 28 May 2019 10:30:12 +0300
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
 <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
 <20190528065153.GB1803@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
Date: Tue, 28 May 2019 10:30:12 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190528065153.GB1803@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.05.2019 9:51, Michal Hocko wrote:
> On Tue 28-05-19 09:25:13, Konstantin Khlebnikov wrote:
>> On 27.05.2019 17:39, Michal Hocko wrote:
>>> On Mon 27-05-19 16:21:56, Michal Hocko wrote:
>>>> On Mon 27-05-19 16:12:23, Michal Hocko wrote:
>>>>> [Cc linux-api. Please always cc this list when proposing a new user
>>>>>    visible api. Keeping the rest of the email intact for reference]
>>>>>
>>>>> On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
>>>> [...]
>>>>>> This implements manual kswapd-style memory reclaim initiated by userspace.
>>>>>> It reclaims both physical memory and cgroup pages. It works in context of
>>>>>> task who calls syscall madvise thus cpu time is accounted correctly.
>>>>
>>>> I do not follow. Does this mean that the madvise always reclaims from
>>>> the memcg the process is member of?
>>>
>>> OK, I've had a quick look at the implementation (the semantic should be
>>> clear from the patch descrition btw.) and it goes all the way up the
>>> hierarchy and finally try to impose the same limit to the global state.
>>> This doesn't really make much sense to me. For few reasons.
>>>
>>> First of all it breaks isolation where one subgroup can influence a
>>> different hierarchy via parent reclaim.
>>
>> madvise(NULL, size, MADV_STOCKPILE) is the same as memory allocation and
>> freeing immediately, but without pinning memory and provoking oom.
>>
>> So, there is shouldn't be any isolation or security issues.
>>
>> At least probably it should be limited with portion of limit (like half)
>> instead of whole limit as it does now.
> 
> I do not think so. If a process is running inside a memcg then it is
> a subject of a limit and that implies an isolation. What you are
> proposing here is to allow escaping that restriction unless I am missing
> something. Just consider the following setup
> 
> 		root (total memory = 2G)
> 		 / \
>             (1G) A   B (1G)
>                     / \
>             (500M) C   D (500M)
> 
> all of them used up close to the limit and a process inside D requests
> shrinking to 250M. Unless I am misunderstanding this implementation
> will shrink D, B root to 250M (which means reclaiming C and A as well)
> and then globally if that was not sufficient. So you have allowed D to
> "allocate" 1,75G of memory effectively, right?

It shrinks not 'size' memory - only while usage + size > limit.
So, after reclaiming 250M in D all other levels will have 250M free.

Of course there might be race because reclaimer works with one level
at the time. Probably it should start from inner level at each iteration.

>   
>>>
>>> I also have a problem with conflating the global and memcg states. Does
>>> it really make any sense to have the same target to the global state
>>> as per-memcg? How are you supposed to use this interface to shrink a
>>> particular memcg or for the global situation with a proportional
>>> distribution to all memcgs?
>>
>> For now this is out of my use cease. This could be done in userspace
>> with multiple daemons in different contexts and connection between them.
>> In this case each daemon should apply pressure only its own level.
> 
> Do you expect all daemons to agree on their shrinking target? Could you
> elaborate? I simply do not see how this can work with memcgs lower in
> the hierarchy having a smaller limit than their parents.
> 

Daemons could distribute pressure among leaves and propagate it into parents.
Together with low-limit this gives enough control over pressure distribution.

