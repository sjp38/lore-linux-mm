Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0997EC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 16:01:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2972080A
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 16:01:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lJ1SbOCQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2972080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 572D98E0028; Wed,  2 Jan 2019 11:01:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 523CF8E0002; Wed,  2 Jan 2019 11:01:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 438A28E0028; Wed,  2 Jan 2019 11:01:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9CE8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:01:33 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id k133so36292480ite.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:01:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MsVRfe43oyzUo0Yy9DI1Z23iK9Sm0kuPZkg3XZE1K0s=;
        b=rK0l3wdcLUN4MXWb48qLrEeuojnkFy3v+pMZy4evpq2Fk8MLkrSQqJiIN87q3K69D+
         ipvegcOPejZ/RExiu4oiBdDjJ/3W/Ul8N0gg7zeXRkGlHiFEsjo0klpyMI4Di7Rkv62m
         cn20MnVQafoPE0iSTb92kNQzdqg6sZtmE0XzGv3jmeJflIHhGzj4oJl0xhJKh9vq2gvR
         Ip7ia8iBDzKKPV3nc05H/m1aXTO/pMW2m/aSlJUI13Ql2Rzr3S5E3Bp/+oM14A7hf2kr
         apf4Hm7uYilub8cEcTiN9w5I9FAtxe6TKjeKT6tjV0Phpbh/uw0zNV8cT/8jQYbcWMC3
         YWgA==
X-Gm-Message-State: AJcUukfBR0s3TeT1R8yWsF8JgSlAakRPLtScETizWmTrbsO8Yulo4Fle
	K0DT8PRV1x+Wdw82zAbmTBw66zh7gAdivTBzfODHA1IQg9DQWbmfUBclTUV6hU3itzY7NVzWjUL
	PUOd+z6cw/lrk3qlu5EGQKdVOHgg2pFQ1s8k9htJeQnDhQddwmP0HH2UcrzI/6yS53Kck96+oDR
	GT6qJH+5KK42jVeTgx77YuOYK6iLisayFDf0okisP0Nc/X1HCaTGUY6sbi6mXOGELz0TZWqldKn
	FXPFq95LBMGT5n7wKpWZhvewtNGRkUD6U3TNaCAHdpIZ6nFkUS6j90Uh5e6Vr0YzJWJyaEOzEJ+
	1Ly/f1XWsNqArYPzLWXjc9HvjMHw9eFLJ0sBNbmgTgT7TUhP/OiPR+2NfZgDDRh2b7XP4rE3ZX3
	U
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr27459092iog.270.1546444892876;
        Wed, 02 Jan 2019 08:01:32 -0800 (PST)
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr27459060iog.270.1546444892285;
        Wed, 02 Jan 2019 08:01:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546444892; cv=none;
        d=google.com; s=arc-20160816;
        b=lmtFnCZP/fch6RKj4kjgwCukuqkuV1INELQl5UKHCg9OGXbgNy/nARmYNuVm2p01c7
         Y9iBXgjdeRcACc2M+barRntYcYXUaYDWxGWDo+wAd/g8yDw0ojwM4gBkS8SbHFNUHgBR
         mcZ/pGL+lsg1W39p+FP5mHEKtQ8wSkqclEkH4vbczZ43OLKIgPGV3CLsxz7GZsgnHHIZ
         THC51SbaU1Ps2MqTMzfD6d1D815Jq82NT2YKOg+rZQgLtI3H0Syh+ARXySP0YhQf3IfT
         CaHkEe8NbylrXIfQNm5UJKhLb8XG05ZqH8bAku1AwY5pPKaauRS8RkJ7MVMrji8PrxVZ
         IVVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MsVRfe43oyzUo0Yy9DI1Z23iK9Sm0kuPZkg3XZE1K0s=;
        b=JwFkZY8kAAnPj3HedppcN08zvuVBAkG1s2+Ajkh9TimDJke37NvLXsbT1C3pP3RLOV
         uvKD21sn2MKLzl/jkFnl05whnW3Lz+gUZON3svKD+fwvJVyYHO2Dgxz8ghFJEGuNBeqv
         ZznWxCroMWH9XlVF7BN3w2VukZANNIHwPnadDr4AbN4O6IUECcEB0x7C1K4ZSeymzfUf
         qZbd2UHLHq9lrkqzFP+9SNe/mZ18c/PiCWZRhfrV8HItuE1OXcmYGhaQaEvc2icnMBe3
         zIjrmM1ltSM2jk/6nNo/9rOgVdLxuXSmu8+B4/IUgKv9bMzkA1grN7p8hxjzLeO9W43E
         4SUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lJ1SbOCQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor6202629iol.146.2019.01.02.08.01.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 08:01:32 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lJ1SbOCQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MsVRfe43oyzUo0Yy9DI1Z23iK9Sm0kuPZkg3XZE1K0s=;
        b=lJ1SbOCQmCiSje2wR9gDYU1HImajNSDmeWnXTZO5rCoBsAlIhL4aDeULEZHby+kCZt
         Dy7MEnhOAlOmcrdzKNRaCiaQFjh+90KMFzwgkHcPcgP0vVE6+k/Ekmadn3AxXZsfpo74
         W1jpRUgSVXtIdhdK+XjvwIGgBqxCVbFQMV3tUFTXzqTjEpWLQukp6dkO1vI0IhiUwy0K
         j2AkiHfDOSen9OICBmdzi2Nrj2KO03eQ+XJcRQUzxCVa87quMvaBrEOvlAn0xUXqZziV
         EUDoESsy1dyF/Xy2ETa3z9veco5gNMNIbOmJnmCg9052AChJeJ1NnNEbIrqgD+cSZqyi
         /6Kg==
X-Google-Smtp-Source: ALg8bN5HLgXn+wb+8Pq1yMVD3WdxS30aST5R0S/BK5ebSCAS1pFN7ptXkkqcqVeJcWYGFT/TRkHUdHcnYC68YJmJM1U=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr30920702iom.11.1546444891786;
 Wed, 02 Jan 2019 08:01:31 -0800 (PST)
MIME-Version: 1.0
References: <0000000000000f35c6057e780d36@google.com> <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
 <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
In-Reply-To: <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 17:01:20 +0100
Message-ID:
 <CACT4Y+Z8M+ODKobZYzWBbPv_y_Y2xNBfuUuX7iVceeLap2Yq3g@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in setup_kmem_cache_node
To: Christopher Lameter <cl@linux.com>
Cc: syzbot <syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com>, 
	Dominique Martinet <asmadeus@codewreck.org>, David Miller <davem@davemloft.net>, 
	Eric Van Hensbergen <ericvh@gmail.com>, LKML <linux-kernel@vger.kernel.org>, 
	Latchesar Ionkov <lucho@ionkov.net>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, v9fs-developer@lists.sourceforge.net, 
	Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102160120.6eQxKX53rdKsVvq6onW41qaNyxAzL-bOQw0bO6WwxiA@z>

On Wed, Jan 2, 2019 at 4:51 PM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 2 Jan 2019, Dmitry Vyukov wrote:
>
> > Am I missing something or __alloc_alien_cache misses check for
> > kmalloc_node result?
> >
> > static struct alien_cache *__alloc_alien_cache(int node, int entries,
> >                                                 int batch, gfp_t gfp)
> > {
> >         size_t memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
> >         struct alien_cache *alc = NULL;
> >
> >         alc = kmalloc_node(memsize, gfp, node);
> >         init_arraycache(&alc->ac, entries, batch);
> >         spin_lock_init(&alc->lock);
> >         return alc;
> > }
> >
>
>
> True _alloc_alien_cache() needs to check for NULL
>
>
> From: Christoph Lameter <cl@linux.com>
> Subject: slab: Alien caches must not be initialized if the allocation of the alien cache failed
>
> Callers of __alloc_alien() check for NULL.
> We must do the same check in __alloc_alien_cache to avoid NULL pointer dereferences
> on allocation failures.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Please add:
Reported-by: syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com

> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c
> +++ linux/mm/slab.c
> @@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
>         struct alien_cache *alc = NULL;
>
>         alc = kmalloc_node(memsize, gfp, node);
> -       init_arraycache(&alc->ac, entries, batch);
> -       spin_lock_init(&alc->lock);
> +       if (alc) {
> +               init_arraycache(&alc->ac, entries, batch);
> +               spin_lock_init(&alc->lock);
> +       }
>         return alc;
>  }
>

