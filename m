Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15221C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E1A222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:48:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E1A222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 667588E0002; Wed, 13 Feb 2019 09:48:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6168C8E0001; Wed, 13 Feb 2019 09:48:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 506548E0002; Wed, 13 Feb 2019 09:48:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E99B38E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:48:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x47so1092238eda.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:48:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3FQOkoN/p58OrfcdLH7/WjDaoN1+OOgFlVy4SRTTICk=;
        b=FUK3d2HpyMji/4U0JJcpHuL9yg/WXJH1hnr+8T9axIWF2U+zhipBdpKfORWw4kpUEj
         vNZc5Fq/npCKjuI7quExJI4gwgQZ3Nv5B3JuP84gN9tDS2P18aW2ZxurYwmpmwQ39ol5
         xKlg/St7XgOUUFzDzWcvvcO6HLmVwv1E5jqiGlQwVoQJPfe/7TAOMu0B8XzMtT//DPts
         2GcJTE2R/Rq0w1JHluHSksP/IbdDo8cB7xfMWcEhz0WNgZ2VJuwV0B/vO1QR7+xtkIn4
         g//0id+qjfLDZw6p6E7dtQ2bYxun1mbyJK/NgT7OpCdhwj63CTr/zOKhZylBofQbOMgD
         4eoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuZ0ZawXv6weQL3wJwdJnSXSqUDcyIfHfq/IRioRtN74ZlB9u8aX
	RHJhIWLRhcutokbATcLGCi5oBsQyDbf4dFwk8c+Bjwe3WQd99gNnXDVJ2z+zwnoVmptuyUfU4hy
	UGeAkXXb90bPzvp3HOMFxbSNbh8Ej92888sw8FZvyfbFUn03PDJWlct+yOEM0qxyCag==
X-Received: by 2002:a50:f102:: with SMTP id w2mr693209edl.65.1550069307485;
        Wed, 13 Feb 2019 06:48:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1j+5B5xsZ17thujZIpx3uZWsdnYX/LltWVOVaiQ6YIeUd30hRz2abTNB+NlIiXsVnvJRG
X-Received: by 2002:a50:f102:: with SMTP id w2mr693149edl.65.1550069306512;
        Wed, 13 Feb 2019 06:48:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550069306; cv=none;
        d=google.com; s=arc-20160816;
        b=BfRPoGwRbpO28mZahjlgJLAJWuV28UhJkJtYlLT8n0HzAE3ewngcyCuEv50OG50JAt
         a8EQ/q7UD8lIdfROKJJV2gyxCT22ltsUjQjIX25xoJQvIXbU9ubRpvxWziyrbsk8cPmb
         /o+HBt3bwshx7PbQuCg63qhQDm1oiERJ5bBSDjlx4CK+Fm8womPNLe3vMth2uKCTS984
         5t2zj3N82/6VxmlN68eRyL1EqIWQP87MBwmorxeWL20Aah14gSncuy5HQ88vryqj9pZv
         fjOZe1zKqbnkMIxUkIjO1d409jWBvTGA7ke0giS0JBcySDxyRWbS+LjbtcIv0erUmoWB
         kCrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3FQOkoN/p58OrfcdLH7/WjDaoN1+OOgFlVy4SRTTICk=;
        b=m5Wh30Ng3Rc/jB0okj/EqJvBm725B8L4ET1P4nsElaCSRhqhM325D13B4RApJk56zx
         PilrxXjE66h3qGG6kSyP2mYSwbmulnSddfAUnV0DSA8s0hN0mMSNcrjjyQLdpx+NE9wB
         fd8MRL6bUIS2MQPGJ69yjNvCa3p9PLFUhtfW7BN5ybOmIJG2kI7EzGRMZZqxctyQruSL
         LEn970CpROfF8m07i2YOAJTt5ZOzqKoiHfHn6kAwzPrTqClsBs7sTOZxtWVcLc8lmmdz
         qOvuydOin/Mh9m2Q2hUsDKBjP4iICVPLsCHTPdqsAp7uFhYVnAH9HakLd7leN+TJxGCC
         R6eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si56152edi.197.2019.02.13.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:48:26 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98141AC96;
	Wed, 13 Feb 2019 14:48:25 +0000 (UTC)
Subject: Re: No system call to determine MAX_NUMNODES?
To: Florian Weimer <fweimer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
 Ralph Campbell <rcampbell@nvidia.com>, Linux MM <linux-mm@kvack.org>,
 longman@redhat.com, Linux API <linux-api@vger.kernel.org>,
 Andi Kleen <ak@linux.intel.com>
References: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
 <CAKgT0UewZP7AE8o__+6TYeKxERBdbnLP9DSzRApZQjzj9Jpeww@mail.gmail.com>
 <4dab8a83-803a-56e0-6bbf-bdf581f2d1b4@suse.cz>
 <87d0nvepf9.fsf@oldenburg2.str.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c4032ba4-4fe6-f591-ee72-6530d449a97c@suse.cz>
Date: Wed, 13 Feb 2019 15:48:25 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <87d0nvepf9.fsf@oldenburg2.str.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 3:25 PM, Florian Weimer wrote:
> * Vlastimil Babka:
> 
>> On 2/7/19 1:27 AM, Alexander Duyck wrote:
>>> On Wed, Feb 6, 2019 at 3:13 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
>>>>
>>>> I was using the latest git://git.cmpxchg.org/linux-mmotm.git and noticed
>>>> a new issue compared to 5.0.0-rc5.
>>>>
>>>> It looks like there is no convenient way to query the kernel's value for
>>>> MAX_NUMNODES yet this is used in kernel_get_mempolicy() to validate the
>>>> 'maxnode' parameter to the GET_MEMPOLICY(2) system call.
>>>> Otherwise, EINVAL is returned.
>>>>
>>>> Searching the internet for get_mempolicy yields some references that
>>>> recommend reading /proc/<pid>/status and parsing the line "Mems_allowed:".
>>>>
>>>> Running "cat /proc/self/status | grep Mems_allowed:" I get:
>>>> With 5.0.0-rc5:
>>>> Mems_allowed:   00000000,00000001
>>>> With 5.0.0-rc5-mm1:
>>>> Mems_allowed:   1
>>>> (both kernels were config'ed with CONFIG_NODES_SHIFT=6)
>>>>
>>>> Clearly, there should be a better way to query MAX_NUMNODES like
>>>> sysconf(), sysctl(), or libnuma.
>>> 
>>> Really we shouldn't need to know that. That just tells us about how
>>> the kernel was built, it doesn't really provide any information about
>>> the layout of the system.
>>> 
>>>> I searched for the patch that changed /proc/self/status but didn't find it.
>>> 
>>> The patch you are looking for is located at:
>>> http://lkml.kernel.org/r/1545405631-6808-1-git-send-email-longman@redhat.com
>>
>> Hmm looks like libnuma [1] uses that /proc/self/status parsing approach for
>> numa_num_possible_nodes() and it's also mentioned in man numa(3), and comment in
>> code mentions that libcpuset does that as well. I'm afraid we can't just break this.
> 
> Oh-oh.  This looks utterly broken to me in the face of process
> migration.

MAX_NUMNODES and thus the layout of /proc/self/status is a build-time constant
of the kernel, so it won't change after migration between VM's if that's what
you're asking. CRIU might be affected if restore is done on kernel with
different MAX_NUMNODES.

> Is this used for anything important?  Perhaps sizing data structures in
> user space?

libnuma seems to parse it only once and then remembering the result for
everything else, so there shouldn't be e.g. mismatch between buffer alloc and
writing to it.

> Thanks,
> Florian
> 

