Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0D29C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 02:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E7D821537
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 02:54:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E7D821537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6A7B8E003B; Mon,  8 Jul 2019 22:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1B748E0032; Mon,  8 Jul 2019 22:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE3208E003B; Mon,  8 Jul 2019 22:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85DEC8E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 22:54:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i27so11532205pfk.12
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 19:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=1YXVxdVlbjP61OVZVlRbACV4q7st4JmnvP5JYUmOe1Q=;
        b=pRRy77KM8V4fDfMQwaLh1nxWCAaXw41H6y7sqIKGOhb22t+jPBBLsiBW9D4xQHRMJ5
         OEPwhwAdWvpf5nQYC4ZHkpjQS+YHbzKAQkxqB9sfUH3ir5UOAhp/rlyPgQBAJwS2/YDC
         jCiVersXFqcXTtAkjpXryLnduKcmJtZ9eZhpvDMT0dKfQAJgBtO9hlIudDOyLTc9sJJ9
         xO7lhOnqXabRxfbrpC/YtJRTqD+zTzxBXqK9UwlSS9aNoJp69U6OBLp/hVkKsPdX4Qgc
         6ih0hXL06iDonaBxOEPLv4FC6LCSZYy3oDREDJCNwSLAy7J2iNxM3xf+zaVSfljq6tpd
         Oz4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAXIocrRRXA6Eqd35dwaLf2CntMtgEn2KI74409WbDVAt6TQgApG
	q8fudm6X0TIAR6q/L28MT6r8xc0LFGDLewDWPgGzrqXGSmEfvE3mgcQpKLqcWHJHaMb7LfqCJWX
	2c0x9oYO5FRDu3eqsN0J13fbxkHwGKbRm7DT9/vDvTAcOPUWlDgJ982Gxp6OU7VcxLg==
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr29306249pls.303.1562640846091;
        Mon, 08 Jul 2019 19:54:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+3iGZDQp6+8gYDkzo8vJbWx1j92e5lhw+5PtpkZ0yr6vfHdkCl2agoqZKeSoJ+Qb84cLy
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr29306165pls.303.1562640845000;
        Mon, 08 Jul 2019 19:54:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562640844; cv=none;
        d=google.com; s=arc-20160816;
        b=I1i2WbkYYCoUBe9GVURhwrE2TZutSrNVYNVKOIMp2SjxGwp90EPm7Y0m9Hzo186QN4
         jpTh1iUh7PE6et1n5XInDmVtUDr5Ti+YZR0ESIFxW8EnieHR87AqlOJvpDPmdxppnPI9
         ncJ7sT2jCLbqU9AWp1C3pYgU8pAJ+6qHGgbgzsFsCkoz0z/at91vRnGzYrimr4JvazyN
         toY0DUX4ryHsJL9iBu0/hiH7I++LKRuOX/0baRzHLNQ9WR4RaMszwIDCzSHxzdfbQeIm
         U+ELKuyAYzd2b2U9/IPi8yANJw4XcpK10F8J+B3BfyBobvJ/kc6MNPOQpcOIgRde0+n8
         sMeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=1YXVxdVlbjP61OVZVlRbACV4q7st4JmnvP5JYUmOe1Q=;
        b=ZFQwoDtp/mvJQTJ5HRh+oSx+4660i715uHw3oyM2iCeBi0VolCGMOPYAZuNAczvZYq
         Uf2c70/5njcoViq73yBXRFQmHs/Y/USrm8VJXvhK8rLXY3p1tmsiipiWp6HvZAb0RM9A
         eHIuPWCfpKKPMf34PxOb2NntR3sqc9E0N85f4znW6wTBuw2vP4/ULPutqDBKRU18MTy1
         HZ9U+pZ5F0494emyYaC7rYvE+/uH5RIK+U33awEkECgil5YdgTU+0kzG7csTjJpzYi8l
         ySJ2JlvoHNbM5ruxIqVb3QUAT7RdLDQwUBwFJEXuHA6m6fMD+ttUit1K/N2DaTACWCqY
         UJgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id 28si20611563pgy.252.2019.07.08.19.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 19:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: e54a938dbb3841b2821206c79fe148af-20190709
X-UUID: e54a938dbb3841b2821206c79fe148af-20190709
Received: from mtkcas07.mediatek.inc [(172.21.101.84)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1677781939; Tue, 09 Jul 2019 10:53:54 +0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by
 mtkmbs08n1.mediatek.inc (172.21.101.55) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 9 Jul 2019 10:53:52 +0800
Received: from [172.21.84.99] (172.21.84.99) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 9 Jul 2019 10:53:52 +0800
Message-ID: <1562640832.9077.32.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov
	<dvyukov@google.com>
CC: Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Matthias Brugger"
	<matthias.bgg@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd
 Bergmann <arnd@arndb.de>, Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov
	<andreyknvl@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen
	<miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	wsd_upstream <wsd_upstream@mediatek.com>
Date: Tue, 9 Jul 2019 10:53:52 +0800
In-Reply-To: <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
	 <1560774735.15814.54.camel@mtksdccf07>
	 <1561974995.18866.1.camel@mtksdccf07>
	 <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
	 <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
> 
> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> > On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >>>>>>>>> This patch adds memory corruption identification at bug report for
> >>>>>>>>> software tag-based mode, the report show whether it is "use-after-free"
> >>>>>>>>> or "out-of-bound" error instead of "invalid-access" error.This will make
> >>>>>>>>> it easier for programmers to see the memory corruption problem.
> >>>>>>>>>
> >>>>>>>>> Now we extend the quarantine to support both generic and tag-based kasan.
> >>>>>>>>> For tag-based kasan, the quarantine stores only freed object information
> >>>>>>>>> to check if an object is freed recently. When tag-based kasan reports an
> >>>>>>>>> error, we can check if the tagged addr is in the quarantine and make a
> >>>>>>>>> good guess if the object is more like "use-after-free" or "out-of-bound".
> >>>>>>>>>
> >>>>>>>>
> >>>>>>>>
> >>>>>>>> We already have all the information and don't need the quarantine to make such guess.
> >>>>>>>> Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> >>>>>>>> otherwise it's use-after-free.
> >>>>>>>>
> >>>>>>>> In pseudo-code it's something like this:
> >>>>>>>>
> >>>>>>>> u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> >>>>>>>>
> >>>>>>>> if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> >>>>>>>>   // out-of-bounds
> >>>>>>>> else
> >>>>>>>>   // use-after-free
> >>>>>>>
> >>>>>>> Thanks your explanation.
> >>>>>>> I see, we can use it to decide corruption type.
> >>>>>>> But some use-after-free issues, it may not have accurate free-backtrace.
> >>>>>>> Unfortunately in that situation, free-backtrace is the most important.
> >>>>>>> please see below example
> >>>>>>>
> >>>>>>> In generic KASAN, it gets accurate free-backrace(ptr1).
> >>>>>>> In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> >>>>>>> programmer misjudge, so they may not believe tag-based KASAN.
> >>>>>>> So We provide this patch, we hope tag-based KASAN bug report is the same
> >>>>>>> accurate with generic KASAN.
> >>>>>>>
> >>>>>>> ---
> >>>>>>>     ptr1 = kmalloc(size, GFP_KERNEL);
> >>>>>>>     ptr1_free(ptr1);
> >>>>>>>
> >>>>>>>     ptr2 = kmalloc(size, GFP_KERNEL);
> >>>>>>>     ptr2_free(ptr2);
> >>>>>>>
> >>>>>>>     ptr1[size] = 'x';  //corruption here
> >>>>>>>
> >>>>>>>
> >>>>>>> static noinline void ptr1_free(char* ptr)
> >>>>>>> {
> >>>>>>>     kfree(ptr);
> >>>>>>> }
> >>>>>>> static noinline void ptr2_free(char* ptr)
> >>>>>>> {
> >>>>>>>     kfree(ptr);
> >>>>>>> }
> >>>>>>> ---
> >>>>>>>
> >>>>>> We think of another question about deciding by that shadow of the first
> >>>>>> byte.
> >>>>>> In tag-based KASAN, it is immediately released after calling kfree(), so
> >>>>>> the slub is easy to be used by another pointer, then it will change
> >>>>>> shadow memory to the tag of new pointer, it will not be the
> >>>>>> KASAN_TAG_INVALID, so there are many false negative cases, especially in
> >>>>>> small size allocation.
> >>>>>>
> >>>>>> Our patch is to solve those problems. so please consider it, thanks.
> >>>>>>
> >>>>> Hi, Andrey and Dmitry,
> >>>>>
> >>>>> I am sorry to bother you.
> >>>>> Would you tell me what you think about this patch?
> >>>>> We want to use tag-based KASAN, so we hope its bug report is clear and
> >>>>> correct as generic KASAN.
> >>>>>
> >>>>> Thanks your review.
> >>>>> Walter
> >>>>
> >>>> Hi Walter,
> >>>>
> >>>> I will probably be busy till the next week. Sorry for delays.
> >>>
> >>> It's ok. Thanks your kindly help.
> >>> I hope I can contribute to tag-based KASAN. It is a very important tool
> >>> for us.
> >>
> >> Hi, Dmitry,
> >>
> >> Would you have free time to discuss this patch together?
> >> Thanks.
> > 
> > Sorry for delays. I am overwhelm by some urgent work. I afraid to
> > promise any dates because the next week I am on a conference, then
> > again a backlog and an intern starting...
> > 
> > Andrey, do you still have concerns re this patch? This change allows
> > to print the free stack.
> 
> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
> Same for previously used tags for better use-after-free identification.
> 

Hi Andrey,

We ever tried to use object itself to determine use-after-free
identification, but tag-based KASAN immediately released the pointer
after call kfree(), the original object will be used by another
pointer, if we use object itself to determine use-after-free issue, then
it has many false negative cases. so we create a lite quarantine(ring
buffers) to record recent free stacks in order to avoid those false
negative situations.

We hope to have one solution to cover all cases and be accurate. Our
patch is configurable feature option, it can provide some programmers to
easy see the tag-based KASAN report.


> > We also have a quarantine for hwasan in user-space. Though it works a
> > bit differently then the normal asan quarantine. We keep a per-thread
> > fixed-size ring-buffer of recent allocations:
> > https://github.com/llvm-mirror/compiler-rt/blob/master/lib/hwasan/hwasan_report.cpp#L274-L284
> > and scan these ring buffers during reports.
> > 

Thanks your information, it looks like the same idea with our patch.

