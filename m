Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FD9C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E982173C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:04:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E982173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370BD6B0003; Tue,  6 Aug 2019 06:04:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 320066B0006; Tue,  6 Aug 2019 06:04:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20FE56B0010; Tue,  6 Aug 2019 06:04:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6B456B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:04:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so53502213eda.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Pn+LVt8fSQyk+7gcK0Vj8y3H5cY3twCTb279ouXlw2w=;
        b=CSTKESyn/hIpw4nUrAxV0wAZkjwqZDzAOtroP6VYrU/lQGkS50kxw1f0dh58S8mI6X
         tr9tkqlCQpblTTd6FRN9vhRGrxMyH3EjxZs9+vDRZW4ZizX6kHXLoGZvbP89Kqpv/gQP
         FOzrrM/z7BY2O21tCLrmGQTmxOszXxRehhC7ttMDFCz5k14v8Xhmu4NWxYNbUllwetBd
         pVobORNmo6pmjBGZ8Lg/xQlJBH8JrhL1OSyQMvYrkbZxZUszFxwVsRQ2WaGS+ipIZsXS
         wd+vnn55BRY46Eqj8CwXCkXYO6HmY5bYSkJYMR7G+ksndRuo0c+88ZmeCULAglkdlWbX
         WS6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVCSGyYPCttvNrnjt5n00tAAJ6QOgVJWLIHxXlGXnx6wrSbn83d
	ByL2qsyY4gmiwIIFcaU1mqj9zBj1jBeyuBsvmhavZLKgzg1scMNHRZzVzPU3K997OIGAnTfndz3
	Oy1C4yezrwDHZ0MEPiwO2VTV6NenwtpY3WAbQyCYHfRKWmkrCDoWz/9v5TLbGuyuSuQ==
X-Received: by 2002:a50:eb0b:: with SMTP id y11mr2866962edp.224.1565085852393;
        Tue, 06 Aug 2019 03:04:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjlI9TdQhLJulC9UBi5jJ5/VyfK6r0pyT0Ifp0OVa4WE+GtS0UbkSxV06A2IN20A+XCmpB
X-Received: by 2002:a50:eb0b:: with SMTP id y11mr2866875edp.224.1565085851336;
        Tue, 06 Aug 2019 03:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565085851; cv=none;
        d=google.com; s=arc-20160816;
        b=VnFcezO3mT27vI+JwpRjx32ph038E0ArRYtoGrYdOQkI7K+lXLqSObtRJpqFxLV9kR
         r8m5yBVjw4j953nMA1vA0hCu9Xclw0ptydseW6vDQJiZ9vqfcp0wifwzSfxwRhtkfBhM
         go5JCjiYSBxHOkwMRCaYeO61vzlU1I5z4RwTjXyD1TJiGtTuDbQ0UZh7VXRCRuo/AF5f
         t4leUy3TpUbBsnrDVu3YNPJlsz2z9/zXX/mpWsCFULCKeTRpCBCdVbS112aS2xSowmuT
         /PNZXiG0XgGWEdbVNFZWL1KVYOiLWCwJbLitJmdp+LjALMjPgLiTHBdyrT+72xdZZVci
         nmZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Pn+LVt8fSQyk+7gcK0Vj8y3H5cY3twCTb279ouXlw2w=;
        b=tF8Gc6yyYNcoLMBXSS8yHTkLyMx7+Cu56N3sygMQ5FtflA8i58iGtn/GGOMIJKSjJ2
         Mho8BlDzHgd7Mc8yv8qa0sKIhiIWXtSJ+EZSNekeVrLLFEOaycFciaPA5KAX07ehtIg8
         mz7haWsXKU9WhyjoJWzlriC1SbDPj12o626Si7xghTCbez0IZj9cIcA/Bc2aRqG1WetY
         ZVg2b0Ssf8EsjG8c9QuHu0u0T0WtNfDivQA2NqPY9yiFW9j/KmjVBfWCw8YpJrN778H/
         AHZ2hp7EuGs7Ya5Xg+hElwt8A4GeT/az088E7A0slFLvQ8aJsy5tgom0nEQSi0sliLc7
         pdkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nq5si27404018ejb.124.2019.08.06.03.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3D61B008;
	Tue,  6 Aug 2019 10:04:10 +0000 (UTC)
Subject: Re: oom-killer
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>,
 Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pankaj.suryawanshi@einfochips.com
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
 <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <df820f66-cf82-b43f-97b6-c92a116fa1a6@suse.cz>
Date: Tue, 6 Aug 2019 12:04:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 5:34 PM, Pankaj Suryawanshi wrote:
> On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
>> > On 8/5/19 1:24 PM, Michal Hocko wrote:
>> > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
>> > > [...]
>> > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
>> > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
>> > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
>> > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
>> > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
>> > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
>> > >> [  728.079587]  r4:d1063c00
>> > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
>> > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
>> > >> [  728.097857]  r4:00808111
>> > >
>> > > The call trace tells that this is a fork (of a usermodhlper but that is
>> > > not all that important.
>> > > [...]
>> > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
>> > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
>> > >
>> > > So this is the only usable zone and you are close to the min watermark
>> > > which means that your system is under a serious memory pressure but not
>> > > yet under OOM for order-0 request. The situation is not great though
>> >
>> > Looking at lowmem_reserve above, wonder if 579 applies here? What does
>> > /proc/zoneinfo say?
> 
> 
> What is  lowmem_reserve[]: 0 0 579 579 ?
> 
> $cat /proc/sys/vm/lowmem_reserve_ratio
> 256     32      32
> 
> $cat /proc/sys/vm/min_free_kbytes
> 16384
> 
> here is cat /proc/zoneinfo (in normal situation not when oom)

Thanks, that shows the lowmem reserve was indeed 0 for the GFP_KERNEL allocation
checking watermarks in the DMA zone. The zone was probably genuinely below min
watermark when the check happened, and things changed while the allocation
failure was printing memory info.

