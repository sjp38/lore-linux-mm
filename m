Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C8E8C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 482BE218D4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 482BE218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C42E6B0003; Thu, 25 Jul 2019 17:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 975386B0005; Thu, 25 Jul 2019 17:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CE78E0002; Thu, 25 Jul 2019 17:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39B906B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:37:18 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j10so21586518wre.18
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lEpeGIugxR8Tv/BvnO5RuF8owDqGYtsZkKwPro2wFZI=;
        b=NR37lQgfYp8yIy8OsoLgF/lhA+uTCF9iEcHg1AngGoyjyVU5ECBwGDpjOpwyYi0SpN
         FlL/3f0dTLhB2oLoBl62YMzch3PAbTZZIzFj6RtC+NmCd4R2B+dQQQk+XbXeMWzLmq8w
         7ggYy0imLXIsPloTPSwhCmZFUcQbqOr8qatY1uExhhBKBm9ZoFvHBXADPUVwS6lOV6xY
         E3jblm6nYUehAQis804wEXE0+sTUGmQygoKhRQdvAFlxH2Foh6i6h/ke5y5A1a9VNcWw
         yajE7Wh0QNdfkcR2Cf3bWROZHT6M6kcBgCv/PNrCiGvvMtL9JNtsmQAlWTHOEzV/28TO
         Gm7Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAU2wHZvTDAMAAXm5eOad1r0wR6OzXZmdcoFlCAvaUdwB803uUHI
	Qg6fd85kTk66WzxnNIbOGCvu9FSuhDEdpARpPSMvKC/2PqF9SP1KTzgUpgcUq1qxh8KQJbIlFIL
	xG6U3U9jpprC1KgmSWFrzyArV+5hZCF3xGOl2V9SD/xmx7kDmmJ2jqY60NfrjEak=
X-Received: by 2002:adf:da4d:: with SMTP id r13mr65661741wrl.281.1564090637802;
        Thu, 25 Jul 2019 14:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfoNMUx5IjPDzQtirFam5D9+Y2IraOFUavZqHVEOJVITsuyBIKkGFe8m2DrFbAfasWsVAp
X-Received: by 2002:adf:da4d:: with SMTP id r13mr65661719wrl.281.1564090637107;
        Thu, 25 Jul 2019 14:37:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564090637; cv=none;
        d=google.com; s=arc-20160816;
        b=BwvwbXxch0Q7IuGv7C6BA0b+GVogHs+CJ/j14CiH9M9XtDZRHIDWrqEmj07rqOdfNU
         VeRmiYy5185Ci1Ks+2qZpwIYKExIqFuoc3xjWyeZFma1mV1/jonaSbpAbBZaeqM6+N/a
         +B9LVIRrcmRzxJUD6vnl10+nZSIw3hKGeA0UdC9Apprmb9IuNgI2jx1r/zEU1X67MGj8
         r9LfSYlUN+VlZbbTn3p1aHoo4KfU6RD7ok5F1psyKlt6o4allBWVqR7HkDQGzfzxQDMV
         68J4gzb84eXGIOXwFgtSisxhuZnRhajsKZ44Hrl0O7n0+YCLlLPpzYDg03YgavR9/Bhw
         pEQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lEpeGIugxR8Tv/BvnO5RuF8owDqGYtsZkKwPro2wFZI=;
        b=J31IFPmKhzxCsQI42x/+inIlNYqNcURi8ImPP/aEyfK3tcJ4daeaXtypDIrOc7yzOa
         tHBwtSxU+ENYcxBe3SjScm/Cfloko22NbjtOc1TsegaYi5oORTFHo95PbCWi4V02KxT6
         JLgGRjb/7d+bKSX7wbSTH5kPdPKEYuYQkAF+oFME3xHtnN5CinVWzJiGDbR3P0ck29Nv
         fxxl1oACdDWGOn+HD492iRviBVoiacXfYYc2vxfawcY5YFSXHIB5uASWgp9w8mRWYzBm
         iIoXXk6om4oHSBSI9GIWnyrW2l0ThjKEEHuNY+ElC5A1FwTw1qTEGad0dTX12IEwZWLq
         NLaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id p5si47343106wrq.214.2019.07.25.14.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jul 2019 14:37:17 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 11097 invoked from network); 25 Jul 2019 23:37:16 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.6]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Thu, 25 Jul 2019 23:37:16 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
Date: Thu, 25 Jul 2019 23:37:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725140117.GC3582@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

Am 25.07.19 um 16:01 schrieb Michal Hocko:
> On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
>> Hello all,
>>
>> i hope i added the right list and people - if i missed someone i would
>> be happy to know.
>>
>> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>> varnish service.
>>
>> It happens that the varnish.service cgroup reaches it's MemoryHigh value
>> and stops working due to throttling.
> 
> What do you mean by "stops working"? Does it mean that the process is
> stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
> what the kernel executing for the process.

The service no longer responses to HTTP requests.

stack switches in this case between:
[<0>] io_schedule+0x12/0x40
[<0>] __lock_page_or_retry+0x1e7/0x4e0
[<0>] filemap_fault+0x42f/0x830
[<0>] __xfs_filemap_fault.constprop.11+0x49/0x120
[<0>] __do_fault+0x57/0x108
[<0>] __handle_mm_fault+0x949/0xef0
[<0>] handle_mm_fault+0xfc/0x1f0
[<0>] __do_page_fault+0x24a/0x450
[<0>] do_page_fault+0x32/0x110
[<0>] async_page_fault+0x1e/0x30
[<0>] 0xffffffffffffffff

and

[<0>] poll_schedule_timeout.constprop.13+0x42/0x70
[<0>] do_sys_poll+0x51e/0x5f0
[<0>] __x64_sys_poll+0xe7/0x130
[<0>] do_syscall_64+0x5b/0x170
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff


>> But i don't understand is that the process itself only consumes 40% of
>> it's cgroup usage.
>>
>> So the other 60% is dirty dentries and inode cache. If i issue an
>> echo 3 > /proc/sys/vm/drop_caches
>>
>> the varnish cgroup memory usage drops to the 50% of the pure process.
>>
>> I thought that the kernel would trigger automatic memory reclaim if a
>> cgroup reaches is memory high value to drop caches.
> 
> Yes, that is indeed the case and the kernel memory (e.g. inodes/dentries
> and others) should be reclaim on the way. Maybe it is harder for the
> reclaim to get rid of those than drop_caches. We need more data.

Tell me what you need ;-)

Stefan

