Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90A788E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 00:06:00 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so36400495pfa.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 21:06:00 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d23si54107902pgm.559.2019.01.03.21.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 21:05:59 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 04 Jan 2019 10:35:58 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
In-Reply-To: <5e55c6e64a2bfd6eed855ea17a34788b@codeaurora.org>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <20181106140638.GN27423@dhcp22.suse.cz>
 <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
 <20181106200823.GT27423@dhcp22.suse.cz>
 <5e55c6e64a2bfd6eed855ea17a34788b@codeaurora.org>
Message-ID: <40a4d5154fbd0006fbe55eb68703bb65@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2018-11-07 11:51, Arun KS wrote:
> On 2018-11-07 01:38, Michal Hocko wrote:
>> On Tue 06-11-18 21:01:29, Arun KS wrote:
>>> On 2018-11-06 19:36, Michal Hocko wrote:
>>> > On Tue 06-11-18 11:33:13, Arun KS wrote:
>>> > > When free pages are done with higher order, time spend on
>>> > > coalescing pages by buddy allocator can be reduced. With
>>> > > section size of 256MB, hot add latency of a single section
>>> > > shows improvement from 50-60 ms to less than 1 ms, hence
>>> > > improving the hot add latency by 60%. Modify external
>>> > > providers of online callback to align with the change.
>>> > >
>>> > > This patch modifies totalram_pages, zone->managed_pages and
>>> > > totalhigh_pages outside managed_page_count_lock. A follow up
>>> > > series will be send to convert these variable to atomic to
>>> > > avoid readers potentially seeing a store tear.
>>> >
>>> > Is there any reason to rush this through rather than wait for counters
>>> > conversion first?
>>> 
>>> Sure Michal.
>>> 
>>> Conversion patch, https://patchwork.kernel.org/cover/10657217/ is 
>>> currently
>>> incremental to this patch.
>> 
>> The ordering should be other way around. Because as things stand with
>> this patch first it is possible to introduce a subtle race prone
>> updates. As I've said I am skeptical the race would matter, really, 
>> but
>> there is no real reason to risk for that. Especially when you have the
>> other (first) half ready.
> 
> Makes sense. I have rebased the preparatory patch on top of -rc1.
> https://patchwork.kernel.org/patch/10670787/

Hello Michal,

Please review version 7 sent,
https://lore.kernel.org/patchwork/patch/1028908/

Regards,
Arun
> 
> Regards,
> Arun
