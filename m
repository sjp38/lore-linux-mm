Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75325C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:38:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E00F6206A3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:38:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E00F6206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6829E6B0291; Mon, 13 May 2019 08:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CB66B0292; Mon, 13 May 2019 08:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FA7A6B0293; Mon, 13 May 2019 08:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id D858B6B0291
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:38:03 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 7so867834ljr.23
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:38:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BNLw4dXHVs+3YbZavyFWQ85r28ai+bzPwKdrCIO8Mms=;
        b=qu28lQMShz3iuV4zVrC7cZt2NfW7DdTdy/trppxk26X83PHiWnfXLCT0HRvHoZWQXJ
         4yU5BB5ihPeHxHBE17lJPeN7w6+IdnTv448Z2Pm4IoE0jVydYlxq/xuv56IVbpnpW65l
         +fqLT6AWdQgsxscLm1sD26tsDQEH6LyCnkBHvoZ9tL4qZOMTJ2XwedPsUle00YHUa7Sf
         uOOXUnmSWQUC+I1a90rFEFpZad6bF0o/3rWHQoTk/WgQYBcQVr1SvgF5Yyuv2oJzMw9C
         IBZpruEAvFJpsoLY/YoqBlCKN2OAaUrJbxIqz2pbYeDlMXEXFkgALmgW7zGiXN7IjpmW
         durQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVHfiENGOxg3G9oqy78L6k/jRPvtNgAb7rTcZBGBDDXgRtPLcYr
	PUrbb2kAUBtA5SS3gMm3wPzaCij8l8Oh0HeYV6Be0GsF/riYpsG8hK3/Pz02m+G4zG50i5r8rMR
	/OH39LfUDnkCZa6KTrOZfR3V9OaOKwt7lGyPLQ6EwSzXs5SHQulbiyw+n3/z6hU+rew==
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr2939020lfi.118.1557751083099;
        Mon, 13 May 2019 05:38:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwynzJFpAn39txAdoOmMi2tPvesoUWbVIhWSpYTYW8D9It5hAEwGDibxHot+KrK3uSGIOxN
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr2938962lfi.118.1557751081764;
        Mon, 13 May 2019 05:38:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557751081; cv=none;
        d=google.com; s=arc-20160816;
        b=lf7vcRltgg9kzb/gRX4qnpXVk8sCAcP0C89FyGAnhH32Gq+Po/jw0mqcKTcycdDbcV
         xApUiCek6mJg9WMoSdYqzvtWVHxdEuFL0mxlYDE4F8GVBZvia74tofwEOWAA1cilMy5y
         rbqfResplNPK7+k3L0COBMF4Qx8XCbUiI74IjuMg8YiY+JO5ik/z0HqgiKeAIp/3kH0L
         9lrTV8cdt08Guw8L4yiiNWe+jAhINvrGBiBeBOWLuHR+EfhH3DY20YDbtVEWXPvyjTuY
         7VVn++PhEp+p8tuO+PmTxBGB6eHy9kDxc++u1Wbvu4KkmA5fq3x+9U7ungc2NtIZErxx
         n4RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BNLw4dXHVs+3YbZavyFWQ85r28ai+bzPwKdrCIO8Mms=;
        b=Dzu/SEiCS1krpjgwthdPV4xB/hM6klbIIgVJ1YAs0abh7bzCT7wofzP2g93OUdX9Nl
         TnNE552qMQVNptUi+QPnacEHUOGWKp5XtE4+S40H1LSTZB4gjQeTsCq95Kvsjo66Sfsw
         COvBSuT2RmhqRJjFaH5wWrZBka2zbhGEJJa3mE7rSV9VjCocRmuIlJsa4ML09tRE1Ok9
         i3JlY7ATBhMiv74tBaqCv44XFtE6Ev4di75iIInJoJ8vBIBZl66SHsnv63ug0tBJrwvL
         qr99kEjBfJD6AWX2k3NhV5v053dVSr4IfzTPt0DKiaqbmTM3yrrlEkRGaqzD9FWu+N9v
         Q5mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w19si10682766lfe.82.2019.05.13.05.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 05:38:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQADM-00063i-Vj; Mon, 13 May 2019 15:37:57 +0300
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Timofey Titovets <nefelim4ag@gmail.com>, Aaron Tomlin <atomlin@redhat.com>,
 linux-mm@kvack.org
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a3870e32-3a27-e6df-fcb2-79080cdd167a@virtuozzo.com>
Date: Mon, 13 May 2019 15:37:56 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.05.2019 14:33, Oleksandr Natalenko wrote:
> Hi.
> 
> On Mon, May 13, 2019 at 01:38:43PM +0300, Kirill Tkhai wrote:
>> On 10.05.2019 10:21, Oleksandr Natalenko wrote:
>>> By default, KSM works only on memory that is marked by madvise(). And the
>>> only way to get around that is to either:
>>>
>>>   * use LD_PRELOAD; or
>>>   * patch the kernel with something like UKSM or PKSM.
>>>
>>> Instead, lets implement a so-called "always" mode, which allows marking
>>> VMAs as mergeable on do_anonymous_page() call automatically.
>>>
>>> The submission introduces a new sysctl knob as well as kernel cmdline option
>>> to control which mode to use. The default mode is to maintain old
>>> (madvise-based) behaviour.
>>>
>>> Due to security concerns, this submission also introduces VM_UNMERGEABLE
>>> vmaflag for apps to explicitly opt out of automerging. Because of adding
>>> a new vmaflag, the whole work is available for 64-bit architectures only.
>>>> This patchset is based on earlier Timofey's submission [1], but it doesn't
>>> use dedicated kthread to walk through the list of tasks/VMAs.
>>>
>>> For my laptop it saves up to 300 MiB of RAM for usual workflow (browser,
>>> terminal, player, chats etc). Timofey's submission also mentions
>>> containerised workload that benefits from automerging too.
>>
>> This all approach looks complicated for me, and I'm not sure the shown profit
>> for desktop is big enough to introduce contradictory vma flags, boot option
>> and advance page fault handler. Also, 32/64bit defines do not look good for
>> me. I had tried something like this on my laptop some time ago, and
>> the result was bad even in absolute (not in memory percentage) meaning.
>> Isn't LD_PRELOAD trick enough to desktop? Your workload is same all the time,
>> so you may statically insert correct preload to /etc/profile and replace
>> your mmap forever.
>>
>> Speaking about containers, something like this may have a sense, I think.
>> The probability of that several containers have the same pages are higher,
>> than that desktop applications have the same pages; also LD_PRELOAD for
>> containers is not applicable. 
> 
> Yes, I get your point. But the intention is to avoid another hacky trick
> (LD_PRELOAD), thus *something* should *preferably* be done on the
> kernel level instead.

I don't think so. Does userspace hack introduce some overhead? It does not
look so. Why should we think about mergeable VMAs in page fault handler?!
This is the last thing we want to think in page fault handler.

Also, there is difficult synchronization in page fault handlers, and it's
easy to make a mistake. So, there is a mistake in [3/4], and you call
ksm_enter() with mmap_sem read locked, while normal way is to call it
with write lock (see madvise_need_mmap_write()).

So, let's don't touch this path. Small optimization for unlikely case will
introduce problems in optimization for likely case in the future.

>> But 1)this could be made for trusted containers only (are there similar
>> issues with KSM like with hardware side-channel attacks?!);
> 
> Regarding side-channel attacks, yes, I think so. Were those openssl guys
> who complained about it?..
> 
>> 2) the most
>> shared data for containers in my experience is file cache, which is not
>> supported by KSM.
>>
>> There are good results by the link [1], but it's difficult to analyze
>> them without knowledge about what happens inside them there.
>>
>> Some of tests have "VM" prefix. What the reason the hypervisor don't mark
>> their VMAs as mergeable? Can't this be fixed in hypervisor? What is the
>> generic reason that VMAs are not marked in all the tests?
> 
> Timofey, could you please address this?
> 
> Also, just for the sake of another piece of stats here:
> 
> $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> 526

This all requires attentive analysis. The number looks pretty big for me.
What are the pages you get merged there? This may be just zero pages,
you have identical.

E.g., your browser want to work fast. It introduces smart schemes,
and preallocates many pages in background (mmap + write 1 byte to a page),
so in further it save some time (no page fault + alloc), when page is
really needed. But your change merges these pages and kills this
optimization. Sounds not good, does this?

I think, we should not think we know and predict better than application
writers, what they want from kernel. Let's people decide themselves
in dependence of their workload. The only exception is some buggy
or old applications, which impossible to change, so force madvise
workaround may help. But only in case there are really such applications...

I'd researched what pages you have duplicated in these 526 MB. Maybe
you find, no action is required or a report to userspace application
to use madvise is needed.

>> In case of there is a fundamental problem of calling madvise, can't we
>> just implement an easier workaround like a new write-only file:
>>
>> #echo $task > /sys/kernel/mm/ksm/force_madvise
>>
>> which will mark all anon VMAs as mergeable for a passed task's mm?
>>
>> A small userspace daemon may write mergeable tasks there from time to time.
>>
>> Then we won't need to introduce additional vm flags and to change
>> anon pagefault handler, and the changes will be small and only
>> related to mm/ksm.c, and good enough for both 32 and 64 bit machines.
> 
> Yup, looks appealing. Two concerns, though:
> 
> 1) we are falling back to scanning through the list of tasks (I guess
> this is what we wanted to avoid, although this time it happens in the
> userspace);

IMO, this should be made only for tasks, which are known to be buggy
(which can't call madvise). Yes, scanning will be required.

> 2) what kinds of opt-out we should maintain? Like, what if force_madvise
> is called, but the task doesn't want some VMAs to be merged? This will
> required new flag anyway, it seems. And should there be another
> write-only file to unmerge everything forcibly for specific task?

For example,

Merge:
#echo $task > /sys/kernel/mm/ksm/force_madvise

Unmerge:
#echo -$task > /sys/kernel/mm/ksm/force_madvise

In case of task don't want to merge some VMA, we just should skip it at all.

But firstly we probably should check, that we really need this, and why
existing applications don't call madvise directly. Now we just don't know,
what happens.

Kirill

P.S. This all above is my opinion. Let's wait, what other people think.

