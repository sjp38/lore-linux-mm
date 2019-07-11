Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E79A6C74A4B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 10:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F1CD2064B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 10:06:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F1CD2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB3998E00B1; Thu, 11 Jul 2019 06:06:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3CD08E0032; Thu, 11 Jul 2019 06:06:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB71A8E00B1; Thu, 11 Jul 2019 06:06:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95EE38E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:06:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so3155595pfo.22
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 03:06:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=lBDaQaXRrUq4knov/Wq1uP79LCOzMma2QenhtGj5Gj0=;
        b=hfdOPkKXoX1+52XFP6LkaVdNUrr/CI+S2LzLqcmeq8NLYi9/SNd4Y39m8DOcYyZwrr
         2t+/Dtp1jXsCIjAVceVg4sA/cCX9pxSCzcDbPfADSm0yi670tG/MTqZcU4vlTD9GPEah
         EUTM/x5LRUwGm2QObLqas1AAv80uuQF6wyDA5DgftrWeOb+AS3r1FU0zkfXMj3Bz/9B2
         9W+qYrXrxvu7b5o1LknDw+TffK8TLkOXORcrlVQXVSPXhSoLNJZpfU4QIyJ1oHFfrKZN
         LbhbO3fjWI7OaK/K7P+Tgg4USffZ2mD/3y4Qlo+U0s1vFzxHIUydYc2hnJigIQfuSK+x
         qohA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAVQfwCEtoE4cSl7eq+gDc6eGUe3Mr7QGLBVm3b1LKdiKC59GInh
	IK0OnbAc2/Mh+zkms0CigmnkWgG3yMEUXhBbRtmKfYeuob1VRnCuYIu5SAZ0em7wmWQ8hJgL4pB
	kb/1TE+zSumnQVt380vROUKRXdWylyl7yDw6zu/S93dgQLjKVFSt61X4kyEsWulf5EA==
X-Received: by 2002:a17:902:b688:: with SMTP id c8mr3626348pls.243.1562839583278;
        Thu, 11 Jul 2019 03:06:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbQycS5Ok9Xbk9cbuDSRSy2LkmCJqFc2Ra68arUn7Y/9DupM1ooDhYndhOyROGWyTsDJ+4
X-Received: by 2002:a17:902:b688:: with SMTP id c8mr3626271pls.243.1562839582528;
        Thu, 11 Jul 2019 03:06:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562839582; cv=none;
        d=google.com; s=arc-20160816;
        b=qJApg2odd/kd660NHknz9Cr7oE6YJ6S3a63xMCqbZL8b/nW5esSDZigwqtBwCvqTLT
         PT9mPCgjHii7wLO9oTYz1NR4SJh0l43DxlQs9A2z1X10kwxzTPZG8702JskX7I1WBfzg
         YM3Qr4Unh1ZOyIU/a1orpwhLawwShKs3a2iklO8TTA0jARr9f1lXfzWjz3xXocRKi/lm
         SBw7+Frintgcsxv956mEThHsKuvVKDl98kl08FWUPEU8ht60AafV5G/iBKrNc8eubfzc
         NemlDTqvh2eFus667dwgFn3QtNFFEDVN3OUQBfwlGkekck2nLOCqnF2anqjC39eo3Uqi
         uZ8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=lBDaQaXRrUq4knov/Wq1uP79LCOzMma2QenhtGj5Gj0=;
        b=i8zvh1AODkqGemt1PgIg/cr8U3nhPKpP9g0SxkbhU0uQKR8wOhwOiEEocveDAZAKpe
         2pJaxxWMAExMN9vWpl7o1v2pNQEQF0tuKFJkiHNe68j4WCjou+ohQPm7pZ7AquT+PQG0
         EEJyvYhs4ImLBrCwgRBACw/A5vT1+tRNc+ZlHxgF0ClTbvD5z2nBNeU92MTUw7IROmM7
         moGr9MrlWoZAyll3MFd9uCjegzJxJ5D2RFVQZcQqI+GRyogNGYp0RJfOqdSEiy6eXSmV
         QDpGXmGdQutXnOjRL4jwDxVoG5EUcANJLJE5CRgCdYOgnF6mYj9YnvJ49rz9OAOKndMg
         dDwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id r4si4617383pgv.195.2019.07.11.03.06.21
        for <linux-mm@kvack.org>;
        Thu, 11 Jul 2019 03:06:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 992731da7b244743b02a101ec454b63e-20190711
X-UUID: 992731da7b244743b02a101ec454b63e-20190711
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 749532910; Thu, 11 Jul 2019 18:06:20 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 11 Jul 2019 18:06:19 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 11 Jul 2019 18:06:19 +0800
Message-ID: <1562839579.5846.12.camel@mtksdccf07>
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
Date: Thu, 11 Jul 2019 18:06:19 +0800
In-Reply-To: <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
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
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-TM-SNTS-SMTP:
	FCA1495ABCFBF051C3A138F429F412BB004A5166313DECBCF8F5873EED71160F2000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
> 
> On 7/9/19 5:53 AM, Walter Wu wrote:
> > On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
> >>
> >> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> >>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> 
> >>>
> >>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
> >>> promise any dates because the next week I am on a conference, then
> >>> again a backlog and an intern starting...
> >>>
> >>> Andrey, do you still have concerns re this patch? This change allows
> >>> to print the free stack.
> >>
> >> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
> >> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
> >> Same for previously used tags for better use-after-free identification.
> >>
> > 
> > Hi Andrey,
> > 
> > We ever tried to use object itself to determine use-after-free
> > identification, but tag-based KASAN immediately released the pointer
> > after call kfree(), the original object will be used by another
> > pointer, if we use object itself to determine use-after-free issue, then
> > it has many false negative cases. so we create a lite quarantine(ring
> > buffers) to record recent free stacks in order to avoid those false
> > negative situations.
> 
> I'm telling that *more* than one free stack and also tags per object can be stored.
> If object reused we would still have information about n-last usages of the object.
> It seems like much easier and more efficient solution than patch you proposing.
> 
To make the object reused, we must ensure that no other pointers uses it
after kfree() release the pointer.
Scenario:
1). The object reused information is valid when no another pointer uses
it.
2). The object reused information is invalid when another pointer uses
it.
Do you mean that the object reused is scenario 1) ?
If yes, maybe we can change the calling quarantine_put() location. It
will be fully use that quarantine, but at scenario 2) it looks like to
need this patch.
If no, maybe i miss your meaning, would you tell me how to use invalid
object information? or?

> As for other concern about this particular patch
>  - It wasn't tested. There is deadlock (sleep in atomic) on the report path which would have been noticed it tested.
we already used it on qemu and ran kasan UT. It look like ok.

>    Also GFP_NOWAIT allocation which fails very noisy and very often, especially in memory constraint enviromnent where tag-based KASAN supposed to be used.
> 
Maybe, we can change it into GFP_KERNEL.

>  - Inefficient usage of memory:
> 	48 bytes (sizeof (qlist_object) + sizeof(kasan_alloc_meta)) per kfree() call seems like a lot. It could be less.
> 
We will think it.

> 	The same 'struct kasan_track' stored twice in two different places (in object and in quarantine).
> 	Basically, at least some part of the quarantine always duplicates information that we already know about
> 	recently freed object. 
> 
> 	Since now we call kmalloc() from kfree() path, every unique kfree() stacktrace now generates additional unique stacktrace that
> 	takes space in stackdepot.
> 
Duplicate information is solved after change the calling
quarantine_put() location.






