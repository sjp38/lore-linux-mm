Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A7FC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B5A7222C0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:26:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B5A7222C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC60D8E0002; Wed, 13 Feb 2019 04:26:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D762B8E0001; Wed, 13 Feb 2019 04:26:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C645E8E0002; Wed, 13 Feb 2019 04:26:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 824A78E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:26:52 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t72so1421090pfi.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:26:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MTob8uIYjM0Kzz0IRR/itK/nCHxP3GKuMWcSWon6HIc=;
        b=uUu96uIz1YBj2hw576yTK6fqlKkbNeU2vZ+cWxFzlhSc9tM2I6tM7TBFk27QkLTO4n
         tY72m6JGYp2CPsCVTfXEUkOuoYDJzgH7yis9y/WbfqznSFudKrsq5id6Lp9QRe2RLZBr
         GBOj2nIXhHox+9v3gL+tiezU7utI/qNLXUqhBbfFagsMb1YQs3XiN+qgJ5vlOvcnkDbc
         p7/XvK/C3D/XHrNl+XTC3meyhyGxCk8nXy3767iOlcTQ8qgNegm+NPyCLAMecWtaeaty
         DfFG8TdjSBClN79d4EOjJl2+aW9op0gEpJAlmI/x/z+p3ynKT2aaSsBMvHpWWnPqy029
         6E/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuahcmezPTEllimtoEfBLoyjUKjjvTRDSxWaoS+qhMAAZ/B9pI15
	cVnyNCWfT7QuowfAqMSOTzO17NFAoG3BBlh9H4UNShQfZbH77okze5bM+fOF2ep1JBbmkEu4fht
	/8yfh7uQJokfxD0TlEO7Z6gJOJne9zXfgnPNODFsBbexF22mBa9CYkP55Tds+ubE64g==
X-Received: by 2002:a17:902:a58c:: with SMTP id az12mr8543583plb.299.1550050012175;
        Wed, 13 Feb 2019 01:26:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYe6DJmE5+Wul6GKHcKLlPWZtDjp8aYn4Okw1mKOYaMPUuWOPfZekTLhVaqZbu3SN7CyciE
X-Received: by 2002:a17:902:a58c:: with SMTP id az12mr8543537plb.299.1550050011390;
        Wed, 13 Feb 2019 01:26:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550050011; cv=none;
        d=google.com; s=arc-20160816;
        b=va9rtpo5sq58trcHrR287kk+DfF8Hv0gN9KcMbBId0yVji3f8jllUmbDYs+GcllWZw
         OrcU+N2bBgxwpdGwwbtKY9gsfQcaD4RNeGckdd6l4gcv11TTOnewrix3p6+jLGKU+BYN
         1bQLircuBUNcsocy+6LuS/cFqOnJFUhXf/0A2ps92REvGJWtefPIEyiugyrOI7HFxOV4
         JtvTbCp+fF87yApMXuG4HAumuirYlCnUUNaDKAiFkblDC+cXISGMEnbtxMOXAlKhkfeK
         jmE5AZjoVbf4Ut9nn64rW1SsUMql5L8GvGAN3rQqiv2cC9QcuUTr4DdgwVXRbN/cjX3P
         3BKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MTob8uIYjM0Kzz0IRR/itK/nCHxP3GKuMWcSWon6HIc=;
        b=gtUDuYXllNeTcXMuCiFXtrw25qJsfXhw9EctwE6fS12oHLaryBAp+PqMNjTfi2eUbu
         LqsUcDKJ79C2GHLxhRnA/FRCd1Al0UqakIHlrSRKZbpVKZNJj/nrBWfVHlh33SCbr/+p
         wfi9e992OF3Coe65ffVJX2ebvieQ7pP8FUP40odx1c5QuhOynn/sACmZKxuaIX/QBl8o
         L1Xr6+UgXLUB6TlEv+AKv7rE9+9GyKILydIIdJpPiHye3gbieLOU8zxmH63MmHGKZZVW
         gjuYF/VaO8BUELmNScRrh1w+II3pw4LeXUy2fmTZDsE8bYaUvVc2xffngryizO3OsYWk
         Kcqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w21si10154250pgk.122.2019.02.13.01.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 01:26:50 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 54122AF9B;
	Wed, 13 Feb 2019 09:26:49 +0000 (UTC)
Subject: Re: No system call to determine MAX_NUMNODES?
To: Alexander Duyck <alexander.duyck@gmail.com>,
 Ralph Campbell <rcampbell@nvidia.com>
Cc: Linux MM <linux-mm@kvack.org>, longman@redhat.com,
 Linux API <linux-api@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
References: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
 <CAKgT0UewZP7AE8o__+6TYeKxERBdbnLP9DSzRApZQjzj9Jpeww@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4dab8a83-803a-56e0-6bbf-bdf581f2d1b4@suse.cz>
Date: Wed, 13 Feb 2019 10:26:48 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UewZP7AE8o__+6TYeKxERBdbnLP9DSzRApZQjzj9Jpeww@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/19 1:27 AM, Alexander Duyck wrote:
> On Wed, Feb 6, 2019 at 3:13 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
>>
>> I was using the latest git://git.cmpxchg.org/linux-mmotm.git and noticed
>> a new issue compared to 5.0.0-rc5.
>>
>> It looks like there is no convenient way to query the kernel's value for
>> MAX_NUMNODES yet this is used in kernel_get_mempolicy() to validate the
>> 'maxnode' parameter to the GET_MEMPOLICY(2) system call.
>> Otherwise, EINVAL is returned.
>>
>> Searching the internet for get_mempolicy yields some references that
>> recommend reading /proc/<pid>/status and parsing the line "Mems_allowed:".
>>
>> Running "cat /proc/self/status | grep Mems_allowed:" I get:
>> With 5.0.0-rc5:
>> Mems_allowed:   00000000,00000001
>> With 5.0.0-rc5-mm1:
>> Mems_allowed:   1
>> (both kernels were config'ed with CONFIG_NODES_SHIFT=6)
>>
>> Clearly, there should be a better way to query MAX_NUMNODES like
>> sysconf(), sysctl(), or libnuma.
> 
> Really we shouldn't need to know that. That just tells us about how
> the kernel was built, it doesn't really provide any information about
> the layout of the system.
> 
>> I searched for the patch that changed /proc/self/status but didn't find it.
> 
> The patch you are looking for is located at:
> http://lkml.kernel.org/r/1545405631-6808-1-git-send-email-longman@redhat.com

Hmm looks like libnuma [1] uses that /proc/self/status parsing approach for
numa_num_possible_nodes() and it's also mentioned in man numa(3), and comment in
code mentions that libcpuset does that as well. I'm afraid we can't just break this.

> I wonder if we shouldn't look at modifying kernel_get_mempolicy and
> the compat call to test for nr_node_ids instead of MAX_NUMNODES since
> the rest of the data would be useless anyway.
> 

[1] https://github.com/numactl/numactl/blob/master/libnuma.c

