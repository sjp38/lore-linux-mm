Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 433B3C43612
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 20:03:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9D5C21872
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 20:03:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GpspPied"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9D5C21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65D828E0106; Fri,  4 Jan 2019 15:03:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60E3B8E00F9; Fri,  4 Jan 2019 15:03:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 525558E0106; Fri,  4 Jan 2019 15:03:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3A28E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 15:03:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id o23so27829164pll.0
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 12:03:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=uKI/AHKX0JyUjvz9YhN2UpQb0lqvTA+uLkQzBS73lt8=;
        b=N/ebnXmEI6TUtHNADttpg6XVUQyAF/ePESk/Mmz7C4bW1S1UJRZEz2JjXuNNzyuIRu
         RxQ81RPjoQEnxiu4V7aSGMqlCLFrxgtmU5U4GoQEnbkEM+7XG41ocANSYP+G8qvwDGV7
         R+8YSpWgKtyXPBt1YCXZhAW18EyEB4Dmr+xjZq8bARr2myktY9iGv/CzwyE5tDRhGMnh
         3H4UHJ2rSaiWfhIZ02UhyujwMfBMrglsWeBcS38eZg+dulebQdKiQ1cRffSzbVYh3Eyw
         M9lbrGIMDixWbg/VJwwuEI3siGKnOfm7hna401JvPD4pqvbql4rlF9LLKRlIXrsfKVMb
         m7kA==
X-Gm-Message-State: AJcUukfDDCI4VdrZX+aLQ7Xz0cDn7Czt6Se1dwrA1nzVdJgGHW28pwcP
	ti9pR/k8GwKvRWdV6HC14S+xGhNgEnpI08BwKC37L9JxL+L+vpYVfbqCMISqcdDP46bI8AqmzL9
	hpZtCRTHYEX60FZ/F/nHu3ugsDk2vIqr/A8imNPSiJ4NXi/oRTuPMamO6E8zKyF+opEm4N4ZH2A
	rQ8m5oLwvDooVcVZ744btTlu0ahhHMH+ZfKER7pqa8tkYuJ/MJkTCzzO9btOg7NMpY0QsskBiF2
	i4l/zlHqNoN+0Y0oK4k/fDjMoPiMGtBaiB4CoK48rHc3vqA/xBbw6k3QAajRtmMuy1XisjCzfr9
	u/BvMTjcS/148oOG7q4xeKwbFN/23/Xqs15NZaH6Qmxzb52nV/luaaNChw2iKmeYmOAm8Qnrf8W
	D
X-Received: by 2002:a63:295:: with SMTP id 143mr2697089pgc.362.1546632235600;
        Fri, 04 Jan 2019 12:03:55 -0800 (PST)
X-Received: by 2002:a63:295:: with SMTP id 143mr2697049pgc.362.1546632234702;
        Fri, 04 Jan 2019 12:03:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546632234; cv=none;
        d=google.com; s=arc-20160816;
        b=YnFZixiFxwVPHw00CClCZNTPKlcnmszhKzjv1lxrRJYBeayC3lXy2a6b0WW3wl6/Du
         mlHr/RkIxyW0i8DPIZwqqPcddiUEtKds+spyJG76nGiBoaBhrgXCnlp83tRWVV5NMAcZ
         3ERF+atE4knMscCLY4PFZ4+E8qx6rRr6zMHF12oqCW32XzOOcq7AyTgruna4olHX6kcG
         3rSarqEOpYYc0vPlqRS7UPb2xui+BKdvYloETNQXCmJ0C1/TJC6LhaaHLkOuCBgjyWqy
         AZiRhkDWV1xfuRcigSSi3nweRBRHLAtBiT3V8/C/gVgu6hjZ5evJtigFaxubm8QuwUlT
         JA1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=uKI/AHKX0JyUjvz9YhN2UpQb0lqvTA+uLkQzBS73lt8=;
        b=fX4ytxEsoD/+Z0y6T8cZKoz2poNZlwFOmAkkP2W5EoYW4O80VyhCIXl2z6RrdH6Eke
         breKEawXvc9PmkXUUucMP8FN44L+Rgoyip9lbolRUBLVD4DDSMQr5MFicZnyw33/qsRA
         dltXYQCpGbvHAObXClRy6nqbEkvXtFbxCTjBhyqyQ18CLPq0W/2QerHeIdRB/icyMTK2
         y6XbUhvvCZtJ/foTj0vOlCCTTtp08XfTTwkjChPz9hXmd5KwjfjzFMzisltUYJlz8s/q
         6SRsqoto146ABmURebbcuIlyRcjFo7ELG1+v8B0UA++sdMBV3i/bPyXQ5UpT9qpi9Z2S
         UbyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GpspPied;
       spf=pass (google.com: domain of 3krwvxackcekr4spwpyrzzrwp.nzxwty58-xxv6lnv.z2r@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KrwvXAcKCEkr4spwpyrzzrwp.nzxwty58-xxv6lnv.z2r@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r2sor27938285pgv.24.2019.01.04.12.03.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 12:03:54 -0800 (PST)
Received-SPF: pass (google.com: domain of 3krwvxackcekr4spwpyrzzrwp.nzxwty58-xxv6lnv.z2r@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GpspPied;
       spf=pass (google.com: domain of 3krwvxackcekr4spwpyrzzrwp.nzxwty58-xxv6lnv.z2r@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KrwvXAcKCEkr4spwpyrzzrwp.nzxwty58-xxv6lnv.z2r@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=uKI/AHKX0JyUjvz9YhN2UpQb0lqvTA+uLkQzBS73lt8=;
        b=GpspPiedLWy4By+huorr5Fo7uBig5NplAKWE+cvBIVWxJ5Y0Vcs7GYP03xTHDMU9LF
         CyOIgfzNkTLpxcLSeSowo52Uyprd2+7+2cElrxuq6mprcQpGOxPpyrCPFGpVC9KNhbaP
         Ce2IwlbbAf7pZi7axtwxGnRHWsNACdNMWC8w6CWna6aLPKgvSQbcVvZNc0il+eO9zyam
         0DC8ACa4H9sr+KEzu5AP8GAZ308Pvb9MCNg18zfk0fkDbjckU8X1HPy/vrmwfVk6F22e
         BFPEZZp+9U98DNUOiBXjzkBtjRlZTqqWIssEO5bWQLVFMwULesgnmkI0Ry42nVtQ2XyZ
         nopg==
X-Google-Smtp-Source: ALg8bN7l3/kviGQ3pulE0Gggr8LyfhyGpGug8yffoz6JoUs00SygGzht6Y4ARXT5rDzsyiwSlGdARZsk7p+c
X-Received: by 2002:a63:e504:: with SMTP id r4mr23689714pgh.107.1546632234102;
 Fri, 04 Jan 2019 12:03:54 -0800 (PST)
Date: Fri, 04 Jan 2019 12:03:51 -0800
In-Reply-To: <88b4d986-0b3c-cbf0-65ad-95f3e8ccd870@linux.alibaba.com>
Message-Id: <xr93y380xk9k.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190103101215.GH31793@dhcp22.suse.cz> <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
 <20190103181329.GW31793@dhcp22.suse.cz> <6f43e926-3bb5-20d1-2e39-1d30bf7ad375@linux.alibaba.com>
 <20190103185333.GX31793@dhcp22.suse.cz> <d610c665-890f-3bf0-1e2a-437150b6ddfb@linux.alibaba.com>
 <20190103192339.GA31793@dhcp22.suse.cz> <88b4d986-0b3c-cbf0-65ad-95f3e8ccd870@linux.alibaba.com>
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
From: Greg Thelen <gthelen@google.com>
To: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104200351.i4HyFey-1ADtfnewpwFMYFMFtX5IMG15y3dVYY7FIKE@z>

Yang Shi <yang.shi@linux.alibaba.com> wrote:

> On 1/3/19 11:23 AM, Michal Hocko wrote:
>> On Thu 03-01-19 11:10:00, Yang Shi wrote:
>>>
>>> On 1/3/19 10:53 AM, Michal Hocko wrote:
>>>> On Thu 03-01-19 10:40:54, Yang Shi wrote:
>>>>> On 1/3/19 10:13 AM, Michal Hocko wrote:
>> [...]
>>>>>> Is there any reason for your scripts to be strictly sequential here? In
>>>>>> other words why cannot you offload those expensive operations to a
>>>>>> detached context in _userspace_?
>>>>> I would say it has not to be strictly sequential. The above script is just
>>>>> an example to illustrate the pattern. But, sometimes it may hit such pattern
>>>>> due to the complicated cluster scheduling and container scheduling in the
>>>>> production environment, for example the creation process might be scheduled
>>>>> to the same CPU which is doing force_empty. I have to say I don't know too
>>>>> much about the internals of the container scheduling.
>>>> In that case I do not see a strong reason to implement the offloding
>>>> into the kernel. It is an additional code and semantic to maintain.
>>> Yes, it does introduce some additional code and semantic, but IMHO, it is
>>> quite simple and very straight forward, isn't it? Just utilize the existing
>>> css offline worker. And, that a couple of lines of code do improve some
>>> throughput issues for some real usecases.
>> I do not really care it is few LOC. It is more important that it is
>> conflating force_empty into offlining logic. There was a good reason to
>> remove reparenting/emptying the memcg during the offline. Considering
>> that you can offload force_empty from userspace trivially then I do not
>> see any reason to implement it in the kernel.
>
> Er, I may not articulate in the earlier email, force_empty can not be 
> offloaded from userspace *trivially*. IOWs the container scheduler may 
> unexpectedly overcommit something due to the stall of synchronous force 
> empty, which can't be figured out by userspace before it actually 
> happens. The scheduler doesn't know how long force_empty would take. If 
> the force_empty could be offloaded by kernel, it would make scheduler's 
> life much easier. This is not something userspace could do.

If kernel workqueues are doing more work (i.e. force_empty processing),
then it seem like the time to offline could grow.  I'm not sure if
that's important.

I assume that if we make force_empty an async side effect of rmdir then
user space scheduler would not be unable to immediately assume the
rmdir'd container memory is available without subjecting a new container
to direct reclaim.  So it seems like user space would use a mechanism to
wait for reclaim: either the existing sync force_empty or polling
meminfo/etc waiting for free memory to appear.

>>>> I think it is more important to discuss whether we want to introduce
>>>> force_empty in cgroup v2.
>>> We would prefer have it in v2 as well.
>> Then bring this up in a separate email thread please.
>
> Sure. Will prepare the patches later.
>
> Thanks,
> Yang

