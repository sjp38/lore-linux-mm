Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5247DC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 18:30:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EE6D22BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 18:30:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EE6D22BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 617036B0005; Fri, 26 Jul 2019 14:30:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C7958E0003; Fri, 26 Jul 2019 14:30:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B79E8E0002; Fri, 26 Jul 2019 14:30:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1C6E6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 14:30:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id g2so26168984wrq.19
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:30:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EwijGTLENdH/sFKFZp8enpUoT8DByntKEIfCeodxIgQ=;
        b=AvzGosuwm8raAyxZ0DAd5R7YOD+Ra8AmiwjPcsJim5EQ79AXcTMXz6PMtwatxp72mv
         JpiyWzu0vsCKtkaXUluxEJyXtnI450sJk45PrY4pJsARN3UuGywWUrhuYsES8x6yqsQs
         LsooYOMtGUJj3ankJk1vRZPj1OLcRZB/MDVxlf0ei9M2kgeL1yPBmJCn00FIUM89XjPi
         iAOE5NN9APlpj4LeMAaQXwiCPJtygLPZzY/TeFaI08+u7yI/UGe4SMYWjg4FHGC8QmtL
         57NlBSujTBn7EkP2+9Ffufl/HTnybRQnL59SQ8Zq8EHEHFFR0XD9dgv7mR+kcRy0nPol
         YZoQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAV5S58g0gAxlKSbwtkU1asXPObl9s3A+dVTdhpl33Cc1s6es2ex
	JFyxqzlgJ9C4MRyfkLyd1VDW29ejMJ2IgpcIj/P9hQE23H2EoRsZPbKChpbE92l8be+YiODCpN5
	wk1hMyRm5NqFW6dG1FFV8aiKdPmUs5DQAyAkUiv79VDtlnU4K3P5aKRbyBRPUsn8=
X-Received: by 2002:a1c:ac81:: with SMTP id v123mr88629663wme.145.1564165838496;
        Fri, 26 Jul 2019 11:30:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8WPAZWrPHzyPiguYJ8EBMa61wpuUitBQPnHz4JlzIeVOEbM162+B1rCmQm61Lh5Vefejz
X-Received: by 2002:a1c:ac81:: with SMTP id v123mr88629624wme.145.1564165837482;
        Fri, 26 Jul 2019 11:30:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564165837; cv=none;
        d=google.com; s=arc-20160816;
        b=OSivtzKkLO/DEgFXD4H9YRdhCIos3sz9fRpAT0cvZsJptDSK0nEiSFpv8fCX+ZPGMA
         Yu/O/mx6cm24cUqn5bNjWejQr7xtEZNwKf3P7/g6Cv2UYT9HjAu5XV/Fws5JR0efVJc0
         UK1IsWwKAwai89ZEkuOLegAKhLs6juKCOH6oETBmEmHDWpXRM9BOW54Gg7GPs8d7QN9S
         af+NZ25nbF9NipPsEvQcCNtIbOGfEpOX+lJJgkonRqKNeaAJdZdz2QoNXNTTiLDBwvD7
         4+nIdSfuWW2s1GhFzY5VJIVIB+xydj08+6e+aL10H5V+DAuFwi9oMr+lTY5gflfr8Ouf
         PbFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EwijGTLENdH/sFKFZp8enpUoT8DByntKEIfCeodxIgQ=;
        b=aXDFJ4tJQdzmBm73Dzf4Pdn9wgFWTi213608LMBJjtoKmFzzpMeIs66Pf38j2DKZZ2
         gWNV3uQiDrW5E4lHY0ooccNyHexHxekT8DOcpvEhZVBsRUtIKVFNOP7RQDelCccyYIeA
         d8HFNWRkSOg2j+0prDehgCKC8a572op9W7uGSimFIF9K03ly1rYxqDr8RD+Y4d0B2csT
         FTCfadn3m6cq4YAW9ASy4XQBFFpa5SOBAvleEJluL+dSm2buXVMAWyodWYUFjPVXzw8+
         kPzl7Ahm5b161ko3xcYU2YB7UJKwXUTRJDQh8BP9wmDLfoWm7fx7XV/SFYqcwSERfKck
         dBew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id m4si12595046wrr.80.2019.07.26.11.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Jul 2019 11:30:37 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 21622 invoked from network); 26 Jul 2019 20:30:36 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.5]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Fri, 26 Jul 2019 20:30:36 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
Date: Fri, 26 Jul 2019 20:30:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726074557.GF6142@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 26.07.19 um 09:45 schrieb Michal Hocko:
> On Thu 25-07-19 23:37:14, Stefan Priebe - Profihost AG wrote:
>> Hi Michal,
>>
>> Am 25.07.19 um 16:01 schrieb Michal Hocko:
>>> On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
>>>> Hello all,
>>>>
>>>> i hope i added the right list and people - if i missed someone i would
>>>> be happy to know.
>>>>
>>>> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>>>> varnish service.
>>>>
>>>> It happens that the varnish.service cgroup reaches it's MemoryHigh value
>>>> and stops working due to throttling.
>>>
>>> What do you mean by "stops working"? Does it mean that the process is
>>> stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
>>> what the kernel executing for the process.
>>
>> The service no longer responses to HTTP requests.
>>
>> stack switches in this case between:
>> [<0>] io_schedule+0x12/0x40
>> [<0>] __lock_page_or_retry+0x1e7/0x4e0
>> [<0>] filemap_fault+0x42f/0x830
>> [<0>] __xfs_filemap_fault.constprop.11+0x49/0x120
>> [<0>] __do_fault+0x57/0x108
>> [<0>] __handle_mm_fault+0x949/0xef0
>> [<0>] handle_mm_fault+0xfc/0x1f0
>> [<0>] __do_page_fault+0x24a/0x450
>> [<0>] do_page_fault+0x32/0x110
>> [<0>] async_page_fault+0x1e/0x30
>> [<0>] 0xffffffffffffffff
>>
>> and
>>
>> [<0>] poll_schedule_timeout.constprop.13+0x42/0x70
>> [<0>] do_sys_poll+0x51e/0x5f0
>> [<0>] __x64_sys_poll+0xe7/0x130
>> [<0>] do_syscall_64+0x5b/0x170
>> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
>> [<0>] 0xffffffffffffffff
> 
> Neither of the two seem to be memcg related.

Yes but at least the xfs one is a page fault - isn't this related?

> Have you tried to get
> several snapshots and see if the backtrace is stable?
No it's not it switches most of the time between these both. But as long
as the xfs one with the page fault is seen it does not serve requests
and that one is seen for at least 1-5s than the poill one is visible and
than the xfs one again for 1-5s.

This happens if i do:
systemctl set-property --runtime varnish.service MemoryHigh=6.5G

if i set:
systemctl set-property --runtime varnish.service MemoryHigh=14G

i never get the xfs handle_mm fault one. This is reproducable.

> tell you whether your application is stuck in a single syscall or they
> are just progressing very slowly (-ttt parameter should give you timing)

Yes it's still going forward but really really slow due to memory
pressure. memory.pressure of varnish cgroup shows high values above 100
or 200.

I can reproduce the same with rsync or other tasks using memory for
inodes and dentries. What i don't unterstand is that the kernel does not
reclaim memory for the userspace process and drops the cache. I can't
believe those entries are hot - as they must be at least some days old
as a fresh process running a day only consumes about 200MB of indoe /
dentries / page cache.

Greets,
Stefan

