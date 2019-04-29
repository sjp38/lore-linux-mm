Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 722B4C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 09:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11CE920652
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 09:25:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11CE920652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C90D6B0003; Mon, 29 Apr 2019 05:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 679B66B0006; Mon, 29 Apr 2019 05:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 566C26B0007; Mon, 29 Apr 2019 05:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0F46B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 05:25:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id a18so12333546wrs.21
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 02:25:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=h3OFNZlc6AsyomiHCZN9csfMCoi5Fu5j7kwL8xvJ/EI=;
        b=dVxeF2WE2cS1GBgElN4InOY3zgQKiohmAtXRhnGlzdARHZLSHNEO4GB+LwZiHT0+nu
         CkantnAc9Nnw26xUYjtaU6NcF5wpFeziHA09UO4T0T5T9GIu2V+fBY5v1R7v/rCl7pr7
         /GYfpPoED1V5U6VkvuAVNJkb/48F9glKFFPR6BOicmi1XzSjGfAfBIraQsxSymiYtPy8
         5VzEOXSSxlA2yM6qfkDrHvuO8P/vW45wOkXO5/tV0l/yIfCb2FtpDMqRzKBU4TS8ABaT
         9o5OX8RTwxor4wASPvBjOTaBrBN+veb+cTksJsWjHKrIrt1CTgGt7zsvVC8W0ur46PjJ
         ifvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAVSWsIxTBzhTaK3Nacx03qpcEi+V1+aRo+iWH4G5i4rQNPlWsZz
	ylOESbtDlRJG+XG9kLtXV+fTv50jvG6TEgbYH/npilviJ/msVDeK1WQa4EQv7AzhYWNEoWDZuK5
	R1abp39tF39OxfAUrLE88G7pruZ966luge4wGyezhFAoiR1hfGMb4yt7A2/M03RI=
X-Received: by 2002:a5d:4ec2:: with SMTP id s2mr25218396wrv.160.1556529953426;
        Mon, 29 Apr 2019 02:25:53 -0700 (PDT)
X-Received: by 2002:a5d:4ec2:: with SMTP id s2mr25218345wrv.160.1556529952442;
        Mon, 29 Apr 2019 02:25:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556529952; cv=none;
        d=google.com; s=arc-20160816;
        b=jqn2R7aB6I8ZVy5hW2/MYIvO5iBlgTlFPfQTgBmPwS5gQBuYYBuhTynzt8nkMXE08m
         vSEMytJT+k5RPqIPQCtvD07wTHiMJyt/qE0SlpDg/jHMqoQt4NMTw2TLYFblsCTuLgTd
         1fGsA7M+g7T39Jiu9wo6odTIwnhA68nC1pzjLPyvA8rfDjczgTok85j16kKBOxBzaCyy
         w/0KX3kYBKtKrb/+bk8Mg4faBrsJ18lErznsMfBVb6AMxnhlm27W3A/iJ/wn5Dy+GyOe
         o8qjJFZvrmzbzXu5Ke/EIIH8HAV92q3ymR6lPJTf+WEFOGLawtNqjcR2LErv+FMkOvun
         3RqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:to:from
         :subject;
        bh=h3OFNZlc6AsyomiHCZN9csfMCoi5Fu5j7kwL8xvJ/EI=;
        b=KE9dGlMWYuYUpKpH3luTnghjR5LOiDxgD0vmj3/NvzqujLwouIq+wa+DFDJckFwkIX
         SCcyTzYy0YIYzGr8VG1JkFg/uqhCYkM8uaFaoDybwg0lWBIe46t+QDSV7VD6r01k6DuL
         FZLvpGQ0OuCIZFm076eV9vhlpDUhuvyKuh0T/4/sQnZo9vYB74iswWiX0upYxBNkupov
         hBCQFWRS9RY1VxGLiy6JpKLFFMqKjfMu/6U+qorSxb7o4azsink08zj7j1k4iH6GfsJR
         3xe5iQkORM/iAKEq1gL1lhLASCjqGo4w/g6bs52+G593GKekIFUFsRaIthykWo9S69H+
         KyHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l8sor20012888wrv.46.2019.04.29.02.25.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 02:25:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqxOoG4OBatYmeSRwTce5Lf9o59n26SnyEGs0poOyhvWeg/ZZSa8RM28nQiZ1fD7lwtHWz1A+Q==
X-Received: by 2002:a5d:4cd1:: with SMTP id c17mr4819108wrt.231.1556529951489;
        Mon, 29 Apr 2019 02:25:51 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id v192sm32733168wme.24.2019.04.29.02.25.49
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 02:25:49 -0700 (PDT)
Subject: Re: memcg causes crashes in list_lru_add
From: Jiri Slaby <jslaby@suse.cz>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
 mm <linux-mm@kvack.org>,
 Linux kernel mailing list <linux-kernel@vger.kernel.org>
References: <f0cfcfa7-74d0-8738-1061-05d778155462@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
Date: Mon, 29 Apr 2019 11:25:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <f0cfcfa7-74d0-8738-1061-05d778155462@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29. 04. 19, 10:16, Jiri Slaby wrote:
> Hi,
> 
> with new enough systemd, one of our systems 100% crashes during boot.
> Kernels I tried are all affected: 5.1-rc7, 5.0.10 stable, 4.12.14.
> 
> The 5.1-rc7 crash:
>> [   12.022637] systemd[1]: Starting Create list of required static device nodes for the current kernel...
>> [   12.023353] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>> [   12.041502] #PF error: [normal kernel read fault]
>> [   12.041502] PGD 0 P4D 0 
>> [   12.041502] Oops: 0000 [#1] SMP NOPTI
>> [   12.041502] CPU: 0 PID: 208 Comm: (kmod) Not tainted 5.1.0-rc7-1.g04c1966-default #1 openSUSE Tumbleweed (unreleased)
>> [   12.041502] Hardware name: Supermicro H8DSP-8/H8DSP-8, BIOS 080011  06/30/2006
>> [   12.041502] RIP: 0010:list_lru_add+0x94/0x170
>> [   12.041502] Code: c6 07 00 66 66 66 90 31 c0 5b 5d 41 5c 41 5d 41 5e 41 5f c3 49 8b 7c 24 20 49 8d 54 24 08 48 85 ff 74 07 e9 46 00 00 00 31 ff <48> 8b 42 08 4c 89 6a 08 49 89 55 00 49 89 45 08 4c 89 28 48 8b 42
>> [   12.041502] RSP: 0018:ffffb11b8091be50 EFLAGS: 00010202
>> [   12.041502] RAX: 0000000000000001 RBX: ffff930b35705a40 RCX: ffff9309cf21ade0
>> [   12.041502] RDX: 0000000000000000 RSI: ffff930ab61bc587 RDI: ffff930a17711000
>> [   12.041502] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
>> [   12.041502] R10: 0000000000000000 R11: 0000000000000008 R12: ffff9309f5f86640
>> [   12.041502] R13: ffff930ab5705a40 R14: 0000000000000001 R15: ffff930a171dc4e0
>> [   12.041502] FS:  00007f42d6ea5940(0000) GS:ffff930ab7800000(0000) knlGS:0000000000000000
>> [   12.041502] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   12.041502] CR2: 0000000000000008 CR3: 0000000057dec000 CR4: 00000000000006f0
>> [   12.041502] Call Trace:
>> [   12.041502]  d_lru_add+0x44/0x50

...

> and even makes the beast booting. memcg has very wrong assumptions on
> 'memcg_nr_cache_ids'. It does not assume it can change later, despite it
> does.
...
> I am not sure why this is machine-dependent. I cannot reproduce on any
> other box.
> 
> Any idea how to fix this mess?

memcg_update_all_list_lrus should take care about resizing the array. So
it looks like list_lru_from_memcg_idx returns a stale pointer to
list_lru_from_kmem and then to list_lru_add. Still investigating.

thanks,
-- 
js
suse labs

