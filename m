Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B249C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DCBE26084
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:20:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ck0fdUx3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DCBE26084
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88D5E6B027A; Thu, 30 May 2019 01:20:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83F1E6B027B; Thu, 30 May 2019 01:20:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72DC16B027C; Thu, 30 May 2019 01:20:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 510CB6B027A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 01:20:15 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id f4so1301533vkg.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 22:20:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Oa2XmYFYaHQCqkjGn+uHZ6oMylXcAxewRNyQ+T2pvSA=;
        b=olUQBxrxPrV0wmrkg1Oj0kuSkdm7BvwjWbEV5rizOarhr+HweEZV1o5T0VWU+xe2Va
         OXcsNfPSqpEL+JoW/EkInPZHbZ/83tL7GzeJk22KXn3yG/cZ8fAuC0SkWWKXDNoOCCdq
         iN6wLwphM/sc4I9GSuw0Emt39+yK/o/WMS//q7JaaMxEP60gLO09voQqWvaYMlh6zPEh
         sKlqVOtVS02XrVN5mbjGTypOWwzvkirarykb+rteaBM2CfzjKT6org57VVD8zqohh4zD
         GI0WOyKPS8SctYUsd5lmzUQdo/HKjqcjQ/etShmLnaKsgYzPV/tsYrir4AMLwHmBr7B4
         zKhw==
X-Gm-Message-State: APjAAAWoMMeFhIiJlORhQpT9WMPY75W5as6VnJcYU6De1QhM5NyZMgy+
	6pJRpQ/xdItNVfgagTl5Y8cSPKqsJBN9ret3iySwlYK67KFrOiyvZM0n2plcZKu+4PGOhmbNABu
	qnt9nW2Wh+7fAMe9yE62Biuz5Ffz6mekd387sloNJpW9K3/+ueq7enW1xTHKoNtl5oA==
X-Received: by 2002:a1f:8251:: with SMTP id e78mr640211vkd.83.1559193614966;
        Wed, 29 May 2019 22:20:14 -0700 (PDT)
X-Received: by 2002:a1f:8251:: with SMTP id e78mr640196vkd.83.1559193614042;
        Wed, 29 May 2019 22:20:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559193614; cv=none;
        d=google.com; s=arc-20160816;
        b=IHLu1hqu9Xa7g2EGBb8ofLk0B1tNPNQkrdQrQiWv4UDEt8KLLjVUrbQ7eE7+QAMGws
         eBJX5PNJmhXITx2lJ+8IiD7XwcuP07BCQXYSRiPbj9Hi2Eli5w7MIeacMZJ2qpWnN0Kd
         CT31YA6r9N5weIwMwjTZIdkzjzIXEBKEvzwXj3qI2kHpK2ad4Ch0FYrRV0Ex4B/vMDUW
         jfmbh10bPhBFFaf51wETABM2PqOHnH3uchU5Zs/5jwaa0eXS73Gn3EgucaIZG1lImOpb
         o6wMhLvz146sEbLm1tDTZNabCr59WkjO+LQSDk2nCQ9PgoJOWK/DJq0u2N7T7v9CH+bZ
         +M8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Oa2XmYFYaHQCqkjGn+uHZ6oMylXcAxewRNyQ+T2pvSA=;
        b=rjpXIaf463jrJm7qypvHSLvFXh/qyU+6NA9qi0tSqt9sfkqs0XuVpUskLgc7CQOIcX
         Diu17rltMIVVn2amVxXv4sPqImm3mjrJbZlkx946TUla/70MoA6CjwV65RVHCHzbo0vo
         7x8iXerW1xjyqPM5+mdrt96yGVt1Mbj3vk3zW7+KIcL0fg6/zDue7kKjfifzZgjCfeDL
         61qSJiEpcWNR39TmwC44UZfM5V29AN8flacAI2AAb9UEJcrr8bGbyUl4Hab4IT6NNo8s
         9JBPaJvbiWkPHyFkAECQPlb86BLqoeM26D1VNwtNLgf1zqp6VhFkWrVjr/zj74Ybkyka
         BorQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ck0fdUx3;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11sor789750vsh.42.2019.05.29.22.20.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 22:20:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ck0fdUx3;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Oa2XmYFYaHQCqkjGn+uHZ6oMylXcAxewRNyQ+T2pvSA=;
        b=ck0fdUx3qlekQ6XD3iyUQ6GxahV8SsA1xj2y/dpxn1bg81IYZ6ANB3rcRNTrZUmExc
         ypDf+MYG5fygkDbeII077c/s/UWa5S2IfP0b1Kbj3V/EJUM/ZCVqp76o6f9Lzf5PcuRx
         AghFTKbCId16wOFLWE/aM9zt5ptOhAAM7MrdGEhBD5XbAVPY8TEGjsOWJnlEVV0Jxhy9
         9lK2+rU0p7MquCsirQ9DUTbUiVF8FdYhlPYvJKOWdWrtoxdixrYA4UM5wcKzrCAn4PWP
         Fvt+KZaGAhx+9YKHV3BPs9aMuyyoVMoLyxXO9Fjkqpg5KYYhVjv1LzoLXqXzFj2tZHIH
         vfvA==
X-Google-Smtp-Source: APXvYqzVoxCIcgDU/3WlEJIDK2NaAgiIm8ROgOtrojeJ+OR5OZLgQtxlKNiC0CU7W9CEYTJndJ1xDTtH30r8CdlnVow=
X-Received: by 2002:a67:2c0f:: with SMTP id s15mr951689vss.48.1559193613809;
 Wed, 29 May 2019 22:20:13 -0700 (PDT)
MIME-Version: 1.0
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
 <20190529162532.GG18589@dhcp22.suse.cz> <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
 <20190529174931.GH18589@dhcp22.suse.cz>
In-Reply-To: <20190529174931.GH18589@dhcp22.suse.cz>
From: Dianzhang Chen <dianzhangchen0@gmail.com>
Date: Thu, 30 May 2019 13:20:01 +0800
Message-ID: <CAFbcbMA6XjZqrgHmG70Vm_a34Rn4tKqoMgQkRBXES2r3+ymYwg@mail.gmail.com>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in kmalloc_slab()
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is possible that a CPU mis-predicts the conditional branch, and
speculatively loads size_index[size_index_elem(size)], even if size >192.
Although this value will subsequently be discarded,
but it can not drop all the effects of speculative execution,
such as the presence or absence of data in caches. Such effects may
form side-channels which can be
observed to extract secret information.


As for "why this particular path a needs special treatment while other
size branches are ok",
i think the other size branches need to treatment as well at first place,
but in code `index = fls(size - 1)` the function `fls` will make the
index at specific range,
so it can not use `kmalloc_caches[kmalloc_type(flags)][index]` to load
arbitury data.
But, still it may load some date that it shouldn't, if necessary, i
think can add array_index_nospec as well.



On Thu, May 30, 2019 at 1:49 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 30-05-19 00:39:53, Dianzhang Chen wrote:
> > It's come from `192+1`.
> >
> >
> > The more code fragment is:
> >
> >
> > if (size <= 192) {
> >
> >     if (!size)
> >
> >         return ZERO_SIZE_PTR;
> >
> >     size = array_index_nospec(size, 193);
> >
> >     index = size_index[size_index_elem(size)];
> >
> > }
>
> OK I see, I could have looked into the code, my bad. But I am still not
> sure what is the potential exploit scenario and why this particular path
> a needs special treatment while other size branches are ok. Could you be
> more specific please?
> --
> Michal Hocko
> SUSE Labs

