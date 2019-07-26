Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E24D1C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9264122ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:28:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9264122ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 245B26B0005; Fri, 26 Jul 2019 08:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F75B8E0003; Fri, 26 Jul 2019 08:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E55C8E0002; Fri, 26 Jul 2019 08:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE1CB6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:28:24 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g2so11617933pgj.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=tf9SlYB3vDxsjrpdAXfoKRzNdUzFpR3V6KOtlIUPDaY=;
        b=s86JQgqvskExAEDtRouXXCsB3UhapBxOLVAI8WngCVLWedr9Y1vBBlYhtzloCgtjO/
         ozSgA5nx+A+paNVLK22uI73bn42YfqYYKLmYcLD7Bz80MfN1C6s6Q3mwc9Afb7VRikqU
         K9jxSW2M4AltreXduqpYrJsNmddjHvMiHQH7zcqyiddxKgBQGrGWD1NmRiFBKDLeqh32
         coIzn9DeMR4UMYqxSv0OjN69xlZC+rHHzLI9TEHwucmgKYGDCyAYAB6hy3alFchhs3+H
         uBHazUWa0o8itWmyqjHPqYlsnUpMZqIFhBYWbeYH4YDE45huORr82TESN6WFhYuxs1Y/
         sfHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAWAN/xAWcVKoKDEy4iygVhwpb0x09mSsO3aexUac17eof7j7MG4
	OtAXQQOVLPb6I1PxbnNYVzjSZvUMJy+bfVRB9wSHQlJ1mf7hRohjcnCXfAnJQNylW/NyXPMti2n
	m+6W1iHGRcgeqzDS5U3wmx84A7TQARRzFSy6fZPT7MkFnGJA5LuB4AN72mj2QLU9/4w==
X-Received: by 2002:aa7:9591:: with SMTP id z17mr22224772pfj.215.1564144104401;
        Fri, 26 Jul 2019 05:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAura/6GA+NJ90YPzfdHaZB0hikMLzIB+uBlVlQ0QSQmdr9qqo1Rh9neFV+zzoIZ6xaaNA
X-Received: by 2002:aa7:9591:: with SMTP id z17mr22224708pfj.215.1564144103437;
        Fri, 26 Jul 2019 05:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564144103; cv=none;
        d=google.com; s=arc-20160816;
        b=z1k98tIHyl57A3EQjBizsUXwHqWcLRTiykmlhUD23jFP2B9FDifx+xkxjKqiLmtNjU
         3qe52mKT8Gol/YONAPY06yiD3TbqrpsNa37tdb7m6tZIbOYzxxN6ra9zfGJGVNL4Rta0
         oZTuhdgi6kY1VBntnmnweDKja4HgAu6wkDgXLcxTuCb4zmx0Z1JqplNuZx5Y3u9sq2Od
         vOfbl5e2G9+XCD0Ry0frTHHF2Uqxtr5+w32MATrMg5lcrihtq6jI4Sq3pFfeHWppaKiM
         r9qjlTx+1sTEB82QuPlwwmX/M2UBqycJaylioKTzDN4O4OQtjg0F2O0jHNBYaPjPSuZg
         z3ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=tf9SlYB3vDxsjrpdAXfoKRzNdUzFpR3V6KOtlIUPDaY=;
        b=w4dnTX9QJ0SXymHM6aTa5I6NEPZvxdl4jTYOEHPh6IlbNcCxvF71+2qpKJqtAAvkN7
         TZwphhoO4E0ZkxKVviXR5kzdl9bqPjNqg+WWhp0A7vVs6oqY556woFPQKmqpzG6xOsG4
         2O4Giosj0rLzy2smYyP4W826f5Snu0ohMiCKQOQI7LH6a8n2sErqcqMsGjG/e4+9EwOU
         n977paw3ZcycFJIqa6g0XoqLMOc+aO/cBpfWAuIVU8ilPpdvQwmo8zdTAInIOQ4QHheO
         FkdnBHU+Wau5NMsM/CtEnsfav/I5aP0AA2qzcY3X3zxf31JY2DyHFH7bC9YCj7uYc48R
         g3hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id v16si19829147pfi.142.2019.07.26.05.28.22
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 05:28:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: c0115c5e4bb04f198b33f101ac812dbd-20190726
X-UUID: c0115c5e4bb04f198b33f101ac812dbd-20190726
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 1220834546; Fri, 26 Jul 2019 20:28:14 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 26 Jul 2019 20:28:17 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 26 Jul 2019 20:28:17 +0800
Message-ID: <1564144097.515.3.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	wsd_upstream <wsd_upstream@mediatek.com>
Date: Fri, 26 Jul 2019 20:28:17 +0800
In-Reply-To: <e62da62a-2a63-3a1c-faeb-9c5561a5170c@virtuozzo.com>
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
	 <1562640832.9077.32.camel@mtksdccf07>
	 <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
	 <1562839579.5846.12.camel@mtksdccf07>
	 <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
	 <1563160001.4793.4.camel@mtksdccf07>
	 <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
	 <1563789162.31223.3.camel@mtksdccf07>
	 <e62da62a-2a63-3a1c-faeb-9c5561a5170c@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 15:00 +0300, Andrey Ryabinin wrote:
> 
> On 7/22/19 12:52 PM, Walter Wu wrote:
> > On Thu, 2019-07-18 at 19:11 +0300, Andrey Ryabinin wrote:
> >>
> >> On 7/15/19 6:06 AM, Walter Wu wrote:
> >>> On Fri, 2019-07-12 at 13:52 +0300, Andrey Ryabinin wrote:
> >>>>
> >>>> On 7/11/19 1:06 PM, Walter Wu wrote:
> >>>>> On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
> >>>>>>
> >>>>>> On 7/9/19 5:53 AM, Walter Wu wrote:
> >>>>>>> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
> >>>>>>>>
> >>>>>>>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> >>>>>>>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >>>>>>
> >>>>>>>>>
> >>>>>>>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
> >>>>>>>>> promise any dates because the next week I am on a conference, then
> >>>>>>>>> again a backlog and an intern starting...
> >>>>>>>>>
> >>>>>>>>> Andrey, do you still have concerns re this patch? This change allows
> >>>>>>>>> to print the free stack.
> >>>>>>>>
> >>>>>>>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
> >>>>>>>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
> >>>>>>>> Same for previously used tags for better use-after-free identification.
> >>>>>>>>
> >>>>>>>
> >>>>>>> Hi Andrey,
> >>>>>>>
> >>>>>>> We ever tried to use object itself to determine use-after-free
> >>>>>>> identification, but tag-based KASAN immediately released the pointer
> >>>>>>> after call kfree(), the original object will be used by another
> >>>>>>> pointer, if we use object itself to determine use-after-free issue, then
> >>>>>>> it has many false negative cases. so we create a lite quarantine(ring
> >>>>>>> buffers) to record recent free stacks in order to avoid those false
> >>>>>>> negative situations.
> >>>>>>
> >>>>>> I'm telling that *more* than one free stack and also tags per object can be stored.
> >>>>>> If object reused we would still have information about n-last usages of the object.
> >>>>>> It seems like much easier and more efficient solution than patch you proposing.
> >>>>>>
> >>>>> To make the object reused, we must ensure that no other pointers uses it
> >>>>> after kfree() release the pointer.
> >>>>> Scenario:
> >>>>> 1). The object reused information is valid when no another pointer uses
> >>>>> it.
> >>>>> 2). The object reused information is invalid when another pointer uses
> >>>>> it.
> >>>>> Do you mean that the object reused is scenario 1) ?
> >>>>> If yes, maybe we can change the calling quarantine_put() location. It
> >>>>> will be fully use that quarantine, but at scenario 2) it looks like to
> >>>>> need this patch.
> >>>>> If no, maybe i miss your meaning, would you tell me how to use invalid
> >>>>> object information? or?
> >>>>>
> >>>>
> >>>>
> >>>> KASAN keeps information about object with the object, right after payload in the kasan_alloc_meta struct.
> >>>> This information is always valid as long as slab page allocated. Currently it keeps only one last free stacktrace.
> >>>> It could be extended to record more free stacktraces and also record previously used tags which will allow you
> >>>> to identify use-after-free and extract right free stacktrace.
> >>>
> >>> Thanks for your explanation.
> >>>
> >>> For extend slub object, if one record is 9B (sizeof(u8)+ sizeof(struct
> >>> kasan_track)) and add five records into slub object, every slub object
> >>> may add 45B usage after the system runs longer. 
> >>> Slub object number is easy more than 1,000,000(maybe it may be more
> >>> bigger), then the extending object memory usage should be 45MB, and
> >>> unfortunately it is no limit. The memory usage is more bigger than our
> >>> patch.
> >>
> >> No, it's not necessarily more.
> >> And there are other aspects to consider such as performance, how simple reliable the code is.
> >>
> >>>
> >>> We hope tag-based KASAN advantage is smaller memory usage. If it’s
> >>> possible, we should spend less memory in order to identify
> >>> use-after-free. Would you accept our patch after fine tune it?
> >>
> >> Sure, if you manage to fix issues and demonstrate that performance penalty of your
> >> patch is close to zero.
> > 
> > 
> > I remember that there are already the lists which you concern. Maybe we
> > can try to solve those problems one by one.
> > 
> > 1. deadlock issue? cause by kmalloc() after kfree()?
> 
> smp_call_on_cpu()

> > 2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
> 
> No, this is not gonna work. Ideally we shouldn't have any allocations there.
> It's not reliable and it hurts performance.
> 
I dont know this meaning, we need create a qobject and put into
quarantine, so may need to call kmem_cache_alloc(), would you agree this
action?

> 
> > 3. check whether slim 48 bytes (sizeof (qlist_object) +
> > sizeof(kasan_alloc_meta)) and additional unique stacktrace in
> > stackdepot?
> > 4. duplicate struct 'kasan_track' information in two different places
> > 
> 
> Yup.
> 
> > Would you have any other concern? or?
> > 
> 
> It would be nice to see some performance numbers. Something that uses slab allocations a lot, e.g. netperf STREAM_STREAM test.
> 
ok, we will do it.


