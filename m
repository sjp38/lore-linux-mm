Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BF0AC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB0FD206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB0FD206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81BEB8E0005; Mon, 29 Jul 2019 03:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A50C8E0002; Mon, 29 Jul 2019 03:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 694028E0005; Mon, 29 Jul 2019 03:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19CC18E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:08:02 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t9so29830584wrx.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 00:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=5e1q7JRSHzyuBPkZ8OX3+Dm5RO0+0nPmbjR6yHN7n8g=;
        b=Zj3+xh8YK1x5AOci9/1HZM0b06AeLGa2KunaYnPGaUr1ebaO+wvyiwLSTIVkpi7IIy
         0EsNKF/Ga04cYTu1bMgwTtQDuvpDn75q6de7SDyxjatuDLNtB92jIlXlvYuw9qJhc3JV
         7q7vzNtzgO/htrrAmwKJRhVrpxceFlX8OfEbvDUbiVLyCduNnGyKU5fPrC/mNT5IGgMy
         KaQP+RqS8HlpzKzbtD0CIrENkZXI8F2aVMap66cYZ6ssSU6l3NPuHI3wIlsy2BvEH0gK
         WQs8rW2gJNSNzCeryVVOOuc6TccGSwJKmgCkh9XwHQZHeH/1k6fiKeJ6DyV9iMqic3DJ
         vbmQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAW3tCAl3O9KIylXFd9Lce7j8dpS02PBmZByg6Cb/DC3x1VBc8nM
	zjGJos0bygoxeNHJq1UYfKmAJDk5ZwF35uvpQ8zZIn868azZoHA92U6RK8IKZwG7T97SBwc57ig
	rWit3d01BGqOG6oo8nCuF80vVp9uxwVmg6GmVoOpaqYvhwQmkXV7pUk7aT5ZSKP8=
X-Received: by 2002:adf:91c2:: with SMTP id 60mr63128515wri.334.1564384081598;
        Mon, 29 Jul 2019 00:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4hssC5YryNiTv72twXaJyRkW+WbS3kZvX03Nf2VnZghMHfam9KpjV5AeSOx4Gi/sNtGED
X-Received: by 2002:adf:91c2:: with SMTP id 60mr63128423wri.334.1564384080651;
        Mon, 29 Jul 2019 00:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564384080; cv=none;
        d=google.com; s=arc-20160816;
        b=UoiGMGXM8EsFs/CfNRlwNmTu8fBu2IvtBF+19Ak+CxCp6kaBKxj2FBPS59Y+eZSrFe
         NfxSf/Wb6XMQKd7ovBZ9nCJQXoQb6oxFN/GWvVDWtkBamHSmxFzCpG0wem+p69nHaL0J
         G5yxLkOFN9vlH/7Osw0ybrWGPlw7NgW3QDZ2CVwhj3Ez0o0jSUGzjS8lXUu1L5HruSb6
         AV5TtR/q+pnYX5Yat8TQJKXYdRehHHH9LOXVhZsa7v0Hg5jWXmDRsnEW17E6z2Qmiwmn
         ZM6GzPUYuafdkh3H4wETEnqemtNHB6y4hDi47jfoECW/6+fycPw9e2Jbw6oZPTDKIISd
         UmsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=5e1q7JRSHzyuBPkZ8OX3+Dm5RO0+0nPmbjR6yHN7n8g=;
        b=dfYnuAt6Q+HoPVSTwlZaTyOuhbPmzD9fC37EIglzZ9C41k9BTQbT/IVnTdjHNK4gl8
         Ez2ds4af1BDsMmpddiDjCtpJtV9yYOZz6HBODvQR/B+vBkih+5esIvZqsOKsHFyqiPMU
         Jtv9zhyHdi7Nsl7qOgTPYKJaIvZ/RFGhnwrVLH5WJ0+H5QQ/s/lvR210ahflieKmVzIE
         YsZPF5R4LIy9M2lWTu+Epv60Fw3kISQb27nhg4d/ZHoouYWGC2gxe4B3LJRNdGHYdtoe
         FSMlgLqfsBcJxrsF1NJxKauJlvCSfskhh/DlJNCJnRVnNQj5oZxKoAtnqQxLNbMh1wix
         B/CA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id f5si44849260wmb.185.2019.07.29.00.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 00:08:00 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 2318 invoked from network); 29 Jul 2019 09:08:00 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.165]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Mon, 29 Jul 2019 09:08:00 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
 <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
 <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
Message-ID: <57de9aed-2eab-b842-4ca9-a5ec8fbf358a@profihost.ag>
Date: Mon, 29 Jul 2019 09:07:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

it might be that i just missunderstood how it works.

This test works absolutely fine without any penalty:

test.sh:
#####
#!/bin/bash

sync
echo 3 >/proc/sys/vm/drop_caches
sync
time find / -xdev -type f -exec cat "{}" \; >/dev/null 2>/dev/null
#####

started with:
systemd-run -pRemainAfterExit=True -- /root/spriebe/test.sh

or

systemd-run --property=MemoryHigh=300M -pRemainAfterExit=True --
/root/spriebe/test.sh

In both cases it takes ~ 1m 45s even though it consumes about 2G of mem
in the first case.

So it seems even though it can only consume a max of 300M in the 2nd
case. It is as fast as the first one without any limit.

I thought until today that the same would happen for varnish. Where's
the difference?

I also tried stuff like:
sysctl -w vm.vfs_cache_pressure=1000000

but the cgroup memory usage of varnish still raises slowly about 100M
per hour. The varnish process itself stays constant at ~5.6G

Greets,
Stefan

Am 28.07.19 um 23:11 schrieb Stefan Priebe - Profihost AG:
> here is a memory.stat output of the cgroup:
> # cat /sys/fs/cgroup/system.slice/varnish.service/memory.stat
> anon 8113229824
> file 39735296
> kernel_stack 26345472
> slab 24985600
> sock 339968
> shmem 0
> file_mapped 38793216
> file_dirty 946176
> file_writeback 0
> inactive_anon 0
> active_anon 8113119232
> inactive_file 40198144
> active_file 102400
> unevictable 0
> slab_reclaimable 2859008
> slab_unreclaimable 22126592
> pgfault 178231449
> pgmajfault 22011
> pgrefill 393038
> pgscan 4218254
> pgsteal 430005
> pgactivate 295416
> pgdeactivate 351487
> pglazyfree 0
> pglazyfreed 0
> workingset_refault 401874
> workingset_activate 62535
> workingset_nodereclaim 0
> 
> Greets,
> Stefan
> 
> Am 26.07.19 um 20:30 schrieb Stefan Priebe - Profihost AG:
>> Am 26.07.19 um 09:45 schrieb Michal Hocko:
>>> On Thu 25-07-19 23:37:14, Stefan Priebe - Profihost AG wrote:
>>>> Hi Michal,
>>>>
>>>> Am 25.07.19 um 16:01 schrieb Michal Hocko:
>>>>> On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
>>>>>> Hello all,
>>>>>>
>>>>>> i hope i added the right list and people - if i missed someone i would
>>>>>> be happy to know.
>>>>>>
>>>>>> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>>>>>> varnish service.
>>>>>>
>>>>>> It happens that the varnish.service cgroup reaches it's MemoryHigh value
>>>>>> and stops working due to throttling.
>>>>>
>>>>> What do you mean by "stops working"? Does it mean that the process is
>>>>> stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
>>>>> what the kernel executing for the process.
>>>>
>>>> The service no longer responses to HTTP requests.
>>>>
>>>> stack switches in this case between:
>>>> [<0>] io_schedule+0x12/0x40
>>>> [<0>] __lock_page_or_retry+0x1e7/0x4e0
>>>> [<0>] filemap_fault+0x42f/0x830
>>>> [<0>] __xfs_filemap_fault.constprop.11+0x49/0x120
>>>> [<0>] __do_fault+0x57/0x108
>>>> [<0>] __handle_mm_fault+0x949/0xef0
>>>> [<0>] handle_mm_fault+0xfc/0x1f0
>>>> [<0>] __do_page_fault+0x24a/0x450
>>>> [<0>] do_page_fault+0x32/0x110
>>>> [<0>] async_page_fault+0x1e/0x30
>>>> [<0>] 0xffffffffffffffff
>>>>
>>>> and
>>>>
>>>> [<0>] poll_schedule_timeout.constprop.13+0x42/0x70
>>>> [<0>] do_sys_poll+0x51e/0x5f0
>>>> [<0>] __x64_sys_poll+0xe7/0x130
>>>> [<0>] do_syscall_64+0x5b/0x170
>>>> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>> [<0>] 0xffffffffffffffff
>>>
>>> Neither of the two seem to be memcg related.
>>
>> Yes but at least the xfs one is a page fault - isn't this related?
>>
>>> Have you tried to get
>>> several snapshots and see if the backtrace is stable?
>> No it's not it switches most of the time between these both. But as long
>> as the xfs one with the page fault is seen it does not serve requests
>> and that one is seen for at least 1-5s than the poill one is visible and
>> than the xfs one again for 1-5s.
>>
>> This happens if i do:
>> systemctl set-property --runtime varnish.service MemoryHigh=6.5G
>>
>> if i set:
>> systemctl set-property --runtime varnish.service MemoryHigh=14G
>>
>> i never get the xfs handle_mm fault one. This is reproducable.
>>
>>> tell you whether your application is stuck in a single syscall or they
>>> are just progressing very slowly (-ttt parameter should give you timing)
>>
>> Yes it's still going forward but really really slow due to memory
>> pressure. memory.pressure of varnish cgroup shows high values above 100
>> or 200.
>>
>> I can reproduce the same with rsync or other tasks using memory for
>> inodes and dentries. What i don't unterstand is that the kernel does not
>> reclaim memory for the userspace process and drops the cache. I can't
>> believe those entries are hot - as they must be at least some days old
>> as a fresh process running a day only consumes about 200MB of indoe /
>> dentries / page cache.
>>
>> Greets,
>> Stefan
>>

