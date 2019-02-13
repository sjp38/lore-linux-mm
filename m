Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 635AFC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFDD222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFDD222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58E228E0002; Wed, 13 Feb 2019 09:25:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53CF38E0001; Wed, 13 Feb 2019 09:25:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42D2E8E0002; Wed, 13 Feb 2019 09:25:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1981A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:25:24 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id i18so2251967qtm.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:25:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=E61FAmuelOOigpHIMx/sFvCSDGzRY0mJW/GICyOlGU8=;
        b=rPPijoX3Yt2NIrhb4HAoIgjB2lOGxATBLWdwIiZfQhMtFRwhakfl87jyJEPMYCXxuW
         Vv4JKCQL2+ovWZVFP29DRhyxPVnIaCkupUfvbB6HZkB+OEndRbHD7g0DC66bJoIRMWZ4
         Exvj6BgvTaKBnlypEZH7ErO+BkZu9NXFLXszY5/S7Y2He6f+6ZgGhJWYyrIkKiUq8Gy1
         Gdq2XNFzvVRXpfGA9QDsyUr/h1sk/CjlGoiuzPYq96uvx1fzt/qUWUgcUF7PP/kZ9rEx
         dQdus8LdbNU4ogC09j5xi4SGZWqsE9/RzF6ZxB0H8PD9dCuPOfRjR9wGno59OCgQ8Qr1
         24wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYWfYOWah/OAcTlU6ZjjNOJ0JzNj5zYJTq7sznUV8c4xozk2T20
	45Tog2ESDTdpR8PWMES9MbF20LExb4Gq94IC4yo43LJ4BersoRsnfzGxHGmrsPoSCwByojWEVyf
	G2JRaWni7+F1bR2vjElUVJskxZ21elllI7hfKeMwImQSR8SzUN1kdcIyWwb+1PlfgYA==
X-Received: by 2002:a0c:98c9:: with SMTP id g9mr579091qvd.150.1550067923842;
        Wed, 13 Feb 2019 06:25:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnfP8GvykW7Byfye/vslv14lp5tWcegqDgbC9sR+7k4s9JPpO6xytEpqU0qYpmUSfAj2xn
X-Received: by 2002:a0c:98c9:: with SMTP id g9mr579027qvd.150.1550067922954;
        Wed, 13 Feb 2019 06:25:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550067922; cv=none;
        d=google.com; s=arc-20160816;
        b=CA1LlJlyj0rwEZp6i5NyZXkBFgbhDy81YS8QkAeyj4QhFpwqKS5JnBnWaVs+Bh2uN6
         63G1y0HcqSEOvLEDKGtXYkoZYuubp4d0TR+iZwFmHILAS4Zz0FcicezlyFeWo6Z/AGrU
         nOe6S1jW20bujyspzOgRs2V9XReOAOb4jRbzSbeCDXmiGsgACegcUhpmq3zBQCEq/VcK
         lNf+p4ZxhxbFrSjmTOB/0jDG0VOl91g/FPc3Q26zNcxdp4vIDpea+/9ofcomDXomwnmK
         TI9MM2tfCxLmJNF5K6tnJeX3vewPE8E/6jmZMQrFOaGyfX6C6qSRJtte1UHHD6Q0aOKp
         mPlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=E61FAmuelOOigpHIMx/sFvCSDGzRY0mJW/GICyOlGU8=;
        b=PUu2CO3d7QbMzs9igdbgQSFvMfuPMEJPFkJXkY0ZbjDoy0uMwXQZbKMJ6PVVv2/aA2
         FoU03B6f4hSMnLq6HzW/NMJkhICfSLPqN6A5FQXlTN+DBVcQH4s4WvnX98mu0QJ5TzBZ
         +sspYd2gtxjVOH9dl+pnEq3cWYevzjdXLKozR6q2xKVc07tXe5ZAAlHWKREZxckZG0H7
         4nFaKSJCC9ac5qz8gyu2f5yl4foEOz1wo7Vww1pHypU9ng0u+Q7J8mE2YOhtLOxKk+7p
         DgYv9p2Jjh8hQLaEoUG4b+YWwoJ1kr7Nyk3h6RUacvjTs32+a3VQWaROLwXTA+ksPJeu
         yCxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si3029829qtn.351.2019.02.13.06.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:25:22 -0800 (PST)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B25B8C0C6C06;
	Wed, 13 Feb 2019 14:25:21 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-219.str.redhat.com [10.33.192.219])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D86715C219;
	Wed, 13 Feb 2019 14:25:15 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,  Ralph Campbell <rcampbell@nvidia.com>,  Linux MM <linux-mm@kvack.org>,  longman@redhat.com,  Linux API <linux-api@vger.kernel.org>,  Andi Kleen <ak@linux.intel.com>
Subject: Re: No system call to determine MAX_NUMNODES?
References: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
	<CAKgT0UewZP7AE8o__+6TYeKxERBdbnLP9DSzRApZQjzj9Jpeww@mail.gmail.com>
	<4dab8a83-803a-56e0-6bbf-bdf581f2d1b4@suse.cz>
Date: Wed, 13 Feb 2019 15:25:14 +0100
In-Reply-To: <4dab8a83-803a-56e0-6bbf-bdf581f2d1b4@suse.cz> (Vlastimil Babka's
	message of "Wed, 13 Feb 2019 10:26:48 +0100")
Message-ID: <87d0nvepf9.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 13 Feb 2019 14:25:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Vlastimil Babka:

> On 2/7/19 1:27 AM, Alexander Duyck wrote:
>> On Wed, Feb 6, 2019 at 3:13 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
>>>
>>> I was using the latest git://git.cmpxchg.org/linux-mmotm.git and noticed
>>> a new issue compared to 5.0.0-rc5.
>>>
>>> It looks like there is no convenient way to query the kernel's value for
>>> MAX_NUMNODES yet this is used in kernel_get_mempolicy() to validate the
>>> 'maxnode' parameter to the GET_MEMPOLICY(2) system call.
>>> Otherwise, EINVAL is returned.
>>>
>>> Searching the internet for get_mempolicy yields some references that
>>> recommend reading /proc/<pid>/status and parsing the line "Mems_allowed:".
>>>
>>> Running "cat /proc/self/status | grep Mems_allowed:" I get:
>>> With 5.0.0-rc5:
>>> Mems_allowed:   00000000,00000001
>>> With 5.0.0-rc5-mm1:
>>> Mems_allowed:   1
>>> (both kernels were config'ed with CONFIG_NODES_SHIFT=6)
>>>
>>> Clearly, there should be a better way to query MAX_NUMNODES like
>>> sysconf(), sysctl(), or libnuma.
>> 
>> Really we shouldn't need to know that. That just tells us about how
>> the kernel was built, it doesn't really provide any information about
>> the layout of the system.
>> 
>>> I searched for the patch that changed /proc/self/status but didn't find it.
>> 
>> The patch you are looking for is located at:
>> http://lkml.kernel.org/r/1545405631-6808-1-git-send-email-longman@redhat.com
>
> Hmm looks like libnuma [1] uses that /proc/self/status parsing approach for
> numa_num_possible_nodes() and it's also mentioned in man numa(3), and comment in
> code mentions that libcpuset does that as well. I'm afraid we can't just break this.

Oh-oh.  This looks utterly broken to me in the face of process
migration.

Is this used for anything important?  Perhaps sizing data structures in
user space?

Thanks,
Florian

