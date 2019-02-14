Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB3C1C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89E95222D6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KAX1yECj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89E95222D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26CA18E0006; Wed, 13 Feb 2019 19:26:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21BA78E0001; Wed, 13 Feb 2019 19:26:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 133BD8E0006; Wed, 13 Feb 2019 19:26:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1AC88E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:26:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id r9so3269477pfb.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:26:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Owq3oTwBjNNWgPEI9Iu9WeIndEYXNUcW4ioW388h7rU=;
        b=C/5oUJU72TjCgE+EaliNBqqC5YU6pzyQYV1LIrRG8YYPIOBz0kdv/CaueRjVkvW83r
         bqj7lIc8rAT2cwYB8N7rnISdGx/MQwR/fEMEniM9LTjFHGf0Mz2arzPvXy8dwjAWfhiD
         A1ThOBF1VZaf+uf1g4Pq61O2uFwAIlYdttCpaVIjWTWiUW5YVcOszyo1QjV4elsO/9ji
         JEyFgdY3unP8Arnyinh0wXb7R2b5kSmwBSAv4mv3S4+90uTQwM99ESbZUzFOpdhaHVON
         3dYT/eNPJeasgk5pqCHf2SG0Q4Y5vS8QRgorG+bitRV2z5OeUwQJ+seWJxz55pjFqcC1
         WZMg==
X-Gm-Message-State: AHQUAubFBoJq7PMe6JkNuc58kzUYHkdSfeJZMkm+gpK2LBTZcdtAeEiF
	jh0dhspKEufZPMXQqlCYegGqDIPH2AfsRZbHHgdco5WjjqAh4gDwjxbRj+FBO8zNfBTBgDNBDoj
	fp34qvnHLNUf7PSBLdhHGikcWKJJMLewln4XM1ryDqwx+Gghj5pSDCIjoM4ZW1JryilJFKSeXPK
	xI/MC4Q1FozCkmAArzH5k8NklWnjoNDmfqCrfGs+4qE8XU3Bsy95LswP/+L9uyL4oVCInm2Mek5
	my+HDxrblTyBzzhWVJAp/usL8x11HUHieqW3j9Yrjv7MWn1Tjw37pyF5uxOw6wwOn2yKlHnNHqq
	bo6y05iFjORJF4NpGdbdEjvJHgMjQP4SwVjhiE14bfa11zHRaJ/zhKngcjG03q6GQwLmrKknKFM
	3
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr1055867plb.58.1550103979475;
        Wed, 13 Feb 2019 16:26:19 -0800 (PST)
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr1055814plb.58.1550103978781;
        Wed, 13 Feb 2019 16:26:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550103978; cv=none;
        d=google.com; s=arc-20160816;
        b=kyj+/2X6Ye78iK1rsZgvD3FTSTdwaKOwWZpxS/5CG0a7ChC1xQBpXrwIqPcPOA7g1j
         6XL/Jh+l4tXiWMtilkGXdPvVLvO4EyaTm7AXy3ZToOMm4a0bO4LcQV91B5VT4SgZDgw/
         sj/GOBUMBkzUSBnu8bE2hho54uK0Gc4yrt1XFNWKTuOzoCCUfwKY3qCZDAFN1vm8nuWb
         f9hJb66YASimxfDOzidUTAR5Cj6qrQdWfL57wq8S8PqJm4ToTFYp0s2cqugDhIxh8psK
         pFkepTRNhHXIEgw7MlUnqKxgS+X081kfbn+Lf91rF1Ph8FGtXoYGinzPHQVJMoTm3RFI
         HKKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Owq3oTwBjNNWgPEI9Iu9WeIndEYXNUcW4ioW388h7rU=;
        b=dfxqTu5hGzZ5ef1lh5ns3X1Au/SLN66VulXYIfh7aPeEPwwNzIdXTA0b3DwSZaOUQi
         EFSM9bCMTSE4l0cxEquaWKJ22mCNLsjcuP5HBY1kghz5LqmY6OEIcbtcuxyXrWNlMU5Z
         ry/M9GGGqvPIOWryB9WSCWfWhunMulinU8ihN75ZwkW5NP5sN/b1dieWmT4od2nAXNrI
         t/q+tVa1xgkosJXfVKQA0lCC7hIb8XfGPyKEUVnX42bKUy9RMxeMjd2oGlJsIg3si1ll
         LBeqGtjdRk1+XHjDGNFsRi4DCg7FZFbbz3NDWdUY8hB6NsmburL/OJSbEGkvvLYGFK6I
         /BDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KAX1yECj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6sor1289771pgs.22.2019.02.13.16.26.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 16:26:18 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KAX1yECj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Owq3oTwBjNNWgPEI9Iu9WeIndEYXNUcW4ioW388h7rU=;
        b=KAX1yECjj/AZld0F/6clNhqkvErUzzvuN57oJ/dJO6chOBe7IDDgdRBPJKSdlljMjn
         6HgYgm+Efm0OXVOEaF5uty5Z8RhxVYAvZTXAyjXMkzmmmsy7TBJpdAVGyl6VIH3GfSdL
         ChZUNN+LqXWAGgvWvHvksccU9Z5XIlLcDPKdqXEQCH/2QjgmuwO0+leFAH0d0usoasCH
         caLe5eXq+ORpVjku1oPT/ctAFQywYluGEA1OP6OfYrIwHRHAwRyg5shV8Cgq8zamM7d+
         Qnkmgy8+/XIffFydQr3ZO2NFFI2Bptu6YUYcqvJ8RY0y9K+EA4WkIxmc0d4LqnDZUeGP
         ILAw==
X-Google-Smtp-Source: AHgI3IaSRScbdiv8Ar/Gk14E+aDZkPswmvEJvq/NTNz5uyqcJNwNJJoEEjqn/PD+IxrQlrKOjyxPzqQGVy+wPpzMWsQ=
X-Received: by 2002:a63:7044:: with SMTP id a4mr874989pgn.359.1550103977952;
 Wed, 13 Feb 2019 16:26:17 -0800 (PST)
MIME-Version: 1.0
References: <20190213020550.82453-1-cai@lca.pw> <CAAeHK+w-EWDivYTNiUAeSUVZVGOpUyxbbcC8_nMM1=CcpsJ9Ug@mail.gmail.com>
 <1550092329.6911.35.camel@lca.pw>
In-Reply-To: <1550092329.6911.35.camel@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 14 Feb 2019 01:26:06 +0100
Message-ID: <CAAeHK+wTcx+mk7ccLG-RtyO6X7TpYp1_BnuP8jBaS4KbGeb70w@mail.gmail.com>
Subject: Re: [PATCH] slub: untag object before slab end
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 10:12 PM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-02-13 at 11:31 +0100, Andrey Konovalov wrote:
> > On Wed, Feb 13, 2019 at 3:06 AM Qian Cai <cai@lca.pw> wrote:
> > >
> > > get_freepointer() could return NULL if there is no more free objects in
> > > the slab. However, it could return a tagged pointer (like
> > > 0x2200000000000000) with KASAN_SW_TAGS which would escape the NULL
> > > object checking in check_valid_pointer() and trigger errors below, so
> > > untag the object before checking for a NULL object there.
> >
> > I think this solution is just masking the issue. get_freepointer()
> > shouldn't return tagged NULLs. Apparently when we save a freelist
> > pointer, the object where the pointer gets written is tagged
> > differently, than this same object when the pointer gets read. I found
> > one case where this happens (the last patch out my 5 patch series),
> > but apparently there are more.
>
> Well, the problem is that,
>
> __free_slab
>   for_each_object(p, s, page_address(page) [1]
>     check_object(s, page, p ...)
>       get_freepointer(s, p)
>
> [1]: p += s->size
>
> page_address() tags the address using page_kasan_tag(page), so each "p" here has
> that tag.

Ah, I see what the issue is. With those 5 patches page_address()
should return 0xff-tagged pointer here, but when we set_freepointer()
the tag indeed might be different. OK, I think that patch that you
linked below is the better way to deal with this. I've added a
detailed comment to it and sent it.

Thanks!

>
> However, at beginning in allocate_slab(), it tags each object with a random tag,
> and then calls set_freepointer(s, p, NULL)
>
> As the result, get_freepointer() returns a tagged NULL because it never be able
> to obtain the original tag of the object anymore, and this calculation is now
> wrong.
>
> return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);
>
> This also explain why this patch also works, as it unifies the tags.
>
> https://marc.info/?l=linux-mm&m=154955366113951&w=2
>
>

