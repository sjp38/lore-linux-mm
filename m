Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D57EC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:46:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 348A1214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:46:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="DeAqgFnB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 348A1214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C06F08E000D; Thu,  1 Aug 2019 07:46:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B90418E0001; Thu,  1 Aug 2019 07:46:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A58CB8E000D; Thu,  1 Aug 2019 07:46:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 831EA8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 07:46:15 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d11so60963007qkb.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 04:46:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=ji9M1yX+YQfbla2NsLs+sY5Cv6jiMB46Tl3q0Srbae8=;
        b=OWAeDGKzMIdCLeHq6c1Gvov+0U0oybh31ZjE7oUkJAnbbAfRMP9NRf3pDNDbSNXfQb
         tDj9WFLL1tmUrG4NPvElOAiIj9kct8Jv6TOnu4Cm7S819ojkth7I4Mcyqs7FiGxJl6l4
         LxLtImiR2DZy5b1FSmjIko0e2QOP7nudulZLSafCH03FyIkZU5puuS08LBa8dtuOu7Zv
         zuym/uYgthXHObSaInjpHACmVXF6SyfmAL6p+7oRv+gl4ZcfxIQOHu8tLkcblqqk5SRm
         x/Dfiiq+JBW6Jc3CkunEQ7wc++3nK3Hnl3LfPNwiBr9DaSM/KplFGBdPYjDRLDly0/XM
         KtzQ==
X-Gm-Message-State: APjAAAXO9ZFvs2BIyL6LP5gVDcSSIUtUGu7J/HV9pAGdSuG0prIJgXb/
	/Y+wr8xz8rfvUU/i9+of5qcsUWj+Bb3EAFqDasnmL53uQREM2iqWeSOVSzHSy4cBLgByQ00jYBV
	lR/+Wl/BG0NMX+waHUbKKYc93kdYsIrjP4qdtPAkD9UNDz5iRTlDORzJ1abd0BE+KSQ==
X-Received: by 2002:a05:620a:310:: with SMTP id s16mr81547443qkm.420.1564659975249;
        Thu, 01 Aug 2019 04:46:15 -0700 (PDT)
X-Received: by 2002:a05:620a:310:: with SMTP id s16mr81547395qkm.420.1564659974253;
        Thu, 01 Aug 2019 04:46:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564659974; cv=none;
        d=google.com; s=arc-20160816;
        b=DVIG+S2coKL+ILxAStdlr8k4L8mwFZDAk0YHZHj2TfwR/L68+1J0p9oTsSrdOXLuve
         radSvtgDX7LLJKjvWCqg2MzGc1O9fxpCUQL4FJbtNqU6iHTY3Nr/4p5NalOE3XqtSCqc
         MBd9V3pLiyiq/CGxLZIDL5c0eBsO9RIAjUBgswnmepplqbp5vRC3weNKPj2UQU/I7hbg
         xtUfy0wc6kDwtRbNtgpH9ylzQxzLmduBu0+VsyGQJSsDN856EDECzlJH3B9OOIxEDODt
         Abz8AQ+9r4wLwt6sOmqlXzsvcgmOufFcrSNHF8Q0smgy7VcsybQL1oHGGV8s7VdnE64d
         EuTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=ji9M1yX+YQfbla2NsLs+sY5Cv6jiMB46Tl3q0Srbae8=;
        b=psV9Bgg6w7Lc9E5nb0r9HZYbrSUKxPAxT0tvN/ykWjGYDkuRjRoL+sgi1gBp6uA07q
         9ZrrswAro76D4JAvikpv55G5U0bKcsM9QF+f4GddBlqNyW34U/tftMT+8mjJ9tASsMR6
         0MQospy2VZxnP6I/T/aqwl5XuCo7WLkGXVOJNJGat4flwvX+84Uvw7yhRyNHbZCN6LWy
         W7qYzPJrJJmgN3RvZQuj4pJRqzecAdjXPNJcTGHpBtVjgEAjFIoXmDLX3Hd6Dwzhc3hO
         SpRw6nCcnPsaMbTzIF76gNnZYtiN5Za8g63b0M9soeNDjOglRL2sU4Dgsyuvk8Gi3+XO
         s9sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=DeAqgFnB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 41sor60820589qvu.48.2019.08.01.04.46.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 04:46:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=DeAqgFnB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=ji9M1yX+YQfbla2NsLs+sY5Cv6jiMB46Tl3q0Srbae8=;
        b=DeAqgFnBS/ODi7Z7oKwA7CiEzCSUtve9oUVSnmmseRmMIDejgfAbdrdaaQHfOSbJyh
         G/5qzqgha8dwdYfvIYnT8lx56A9Oc3kz4XzulYsJUdC4ur1esvlRDIubDEGdby/dvn5X
         vFeUteP296yILmYSMf4/E3/y7K0FljbPuLGIgiYZEF3S5Ol5lA1GvFEF+uY0FJ0ck1KL
         iVcupjGeufbu/HhEG7G2Xj8Q9f87C5P/a0ok3xVwJkVksx88uMdiv6Jlaq/rDsD+hnCV
         j1Pm2DzjKVQxL2vmTzo0dYpsBgQtUNbJqy4pSR6sdmMsC+wPsNFIhRdO43AyyCocJgXj
         1jSg==
X-Google-Smtp-Source: APXvYqxQzX6GSyEt/KYH4tIGLdfmqpWTbK24pum1MnBSCFJ90L7fLUP908m18PqJbphN1k7Ldv4qtQ==
X-Received: by 2002:a05:6214:42e:: with SMTP id a14mr94443239qvy.19.1564659973840;
        Thu, 01 Aug 2019 04:46:13 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id 39sm39030400qts.41.2019.08.01.04.46.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 04:46:12 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
 breaks OOM with swap
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190801065108.GA179251@google.com>
Date: Thu, 1 Aug 2019 07:46:10 -0400
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <53837B9C-7E73-47DA-9373-5E989A9EEC4F@lca.pw>
References: <1564503928.11067.32.camel@lca.pw>
 <20190731053444.GA155569@google.com> <1564589346.11067.38.camel@lca.pw>
 <1564597080.11067.40.camel@lca.pw> <20190801065108.GA179251@google.com>
To: Minchan Kim <minchan@kernel.org>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 1, 2019, at 2:51 AM, Minchan Kim <minchan@kernel.org> wrote:
>=20
> On Wed, Jul 31, 2019 at 02:18:00PM -0400, Qian Cai wrote:
>> On Wed, 2019-07-31 at 12:09 -0400, Qian Cai wrote:
>>> On Wed, 2019-07-31 at 14:34 +0900, Minchan Kim wrote:
>>>> On Tue, Jul 30, 2019 at 12:25:28PM -0400, Qian Cai wrote:
>>>>> OOM workloads with swapping is unable to recover with linux-next =
since
>>>>> next-
>>>>> 20190729 due to the commit "mm: account nr_isolated_xxx in
>>>>> [isolate|putback]_lru_page" breaks OOM with swap" [1]
>>>>>=20
>>>>> [1] =
https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kerne
>>>>> l.
>>>>> org/
>>>>> T/#mdcd03bcb4746f2f23e6f508c205943726aee8355
>>>>>=20
>>>>> For example, LTP oom01 test case is stuck for hours, while it =
finishes in
>>>>> a
>>>>> few
>>>>> minutes here after reverted the above commit. Sometimes, it prints =
those
>>>>> message
>>>>> while hanging.
>>>>>=20
>>>>> [  509.983393][  T711] INFO: task oom01:5331 blocked for more than =
122
>>>>> seconds.
>>>>> [  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 =
#7
>>>>> [  509.983447][  T711] "echo 0 > =
/proc/sys/kernel/hung_task_timeout_secs"
>>>>> disables this message.
>>>>> [  509.983477][  T711] oom01           D24656  5331   5157 =
0x00040000
>>>>> [  509.983513][  T711] Call Trace:
>>>>> [  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8
>>>>> (unreliable)
>>>>> [  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
>>>>> __switch_to+0x3a4/0x520
>>>>> [  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
>>>>> __schedule+0x2fc/0x950
>>>>> [  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68]
>>>>> schedule+0x58/0x150
>>>>> [  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
>>>>> rwsem_down_read_slowpath+0x4b4/0x630
>>>>> [  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
>>>>> down_read+0x12c/0x240
>>>>> [  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
>>>>> __do_page_fault+0x6f8/0xee0
>>>>> [  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
>>>>> handle_page_fault+0x18/0x38
>>>>=20
>>>> Thanks for the testing! No surprise the patch make some bugs =
because
>>>> it's rather tricky.
>>>>=20
>>>> Could you test this patch?
>>>=20
>>> It does help the situation a bit, but the recover speed is still way =
slower
>>> than
>>> just reverting the commit "mm: account nr_isolated_xxx in
>>> [isolate|putback]_lru_page". For example, on this powerpc system, it =
used to
>>> take 4-min to finish oom01 while now still take 13-min.
>>>=20
>>> The oom02 (testing NUMA mempolicy) takes even longer and I gave up =
after 26-
>>> min
>>> with several hang tasks below.
>>=20
>> Also, oom02 is stuck on an x86 machine.
>=20
> Yeb, above my patch had a bug to test page type after page was freed.
> However, after the review, I found other bugs but I don't think it's
> related to your problem, either. Okay, then, let's revert the patch.
>=20
> Andrew, could you revert the below patch?
> "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
>=20
> It's just clean up patch and isn't related to new madvise hint system =
call now.
> Thus, it shouldn't be blocker.
>=20
> Anyway, I want to fix the problem when I have available time.
> Qian, What's the your config and system configuration on x86?
> Is it possible to reproduce in qemu?
> It would be really helpful if you tell me reproduce step on x86.

https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config

The config could work in Openstack, and I never tried in QEMU. It might =
need
a few modification here or there. The reproduced x86 server is,

HPE ProLiant DL385 Gen10
AMD EPYC 7251 8-Core Processor
Smart Storage PQI 12G SAS/PCIe 3
Memory: 32768 MB
NUMA Nodes: 8=

