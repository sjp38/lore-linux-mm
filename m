Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B895BC4740C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 00:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 591AC2082C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 00:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="htQl4RsZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 591AC2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A23616B0003; Mon,  9 Sep 2019 20:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ACD56B0006; Mon,  9 Sep 2019 20:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8737A6B0007; Mon,  9 Sep 2019 20:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFF46B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:52:53 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0A5DEAC14
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:52:53 +0000 (UTC)
X-FDA: 75917186226.06.work46_706e806a9883a
X-HE-Tag: work46_706e806a9883a
X-Filterd-Recvd-Size: 4194
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:52:52 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id z26so6293801oto.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 17:52:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nGIIao9PdFSLqjKhUlXcUfbYL/hFNuXa3CP5/F54v8M=;
        b=htQl4RsZD/SoZ/vc52gD8t3b50B7xySrWXQ7BLNx7V0jbJLA5b9RhJn2wyqnyWLSv4
         ApKclrkm7kzU9kr0b2RpyLy2x2YU2Eq+b7BV+QtnEPvFfBnZO+ZyUbI13yj+BHU6xPKx
         1xJ+4apj8ckZWJtLPpVkQECrxSxK7IA9IEeEzEXHOFDAosZ0gFT4UhOuPywHXDgykGwO
         7Y9fy0jC1Rpx3o/nmO4hrTf7Jyv7XrsFnYiaIR/eSOJ6mT7WnD+dkowkZAJQxtUmK5Yj
         owIO8eanjx7Fi2sViZkk8H6w3RyLAWzBe7zsV6BNOfd3RsgH5yv0Ma1mDrFnEa3Na/Rm
         UrGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nGIIao9PdFSLqjKhUlXcUfbYL/hFNuXa3CP5/F54v8M=;
        b=ooDDs4EhE6WE6H/giwy2hf6SwEjwLx6mZaXo8u93XKBZgbJfYGzZpEsPBW7mACyRsB
         Hw6zr4fvXE6vMtGAJMZc4BcBEzx+XoYjZv6rPhOCVaNASUHUmytUKQ5qojlN85EukWL1
         FsfiVWUTro1AsmFgZvy9rjObufOiskuh0MBaezF+hmnTheJwjAGRkGlSFRg96q+DY0TB
         ts03LodfqDrLqHCpN2pMYVOBx1ph80ZzTWWVhEfg54LRa5UIvLtKL0kFmHd6a+KvhY+2
         2X7r7a4Ig/1Kzou7BjefsBqz8fqa3eaKH0CWSXbogAnihy87bw6C7+stKEllk+0T3I7B
         1eKQ==
X-Gm-Message-State: APjAAAUn6RMrCeENdjabbJ9qrQFfM9M+VdrA/p4KJaiob5m5IEbzKX9Y
	Sw8XeDqkPTX+30qBwIjT4/anDazWg/FjbPWivqw=
X-Google-Smtp-Source: APXvYqzkQoPCx4SYbSI7XLeNrk+DA2aad7QI5zqB6UhLaP/Kt2foPN9VkhR43wq0JloRyhoYwN5OeXtAOrbv8Rh0w3Y=
X-Received: by 2002:a9d:12e4:: with SMTP id g91mr21315054otg.368.1568076771758;
 Mon, 09 Sep 2019 17:52:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190903160430.1368-1-lpf.vector@gmail.com> <20190903160430.1368-2-lpf.vector@gmail.com>
 <4e9a237f-2370-0f55-34d2-1fbb9334bf88@suse.cz> <CAD7_sbEwwqp_ONzYxPQfBDORH4g2Du=LKt=eWf+6SsLgtysBmA@mail.gmail.com>
 <3a95d20d-ccf9-bd45-2db3-380cc3e0cd17@rasmusvillemoes.dk>
In-Reply-To: <3a95d20d-ccf9-bd45-2db3-380cc3e0cd17@rasmusvillemoes.dk>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 10 Sep 2019 08:52:40 +0800
Message-ID: <CAD7_sbHV=tXrZaBuQuifVznFMUf13hs7t_QcgFVmrCdMHT4Ytg@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm, slab: Make kmalloc_info[] contain all types of names
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Christopher Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 2:30 AM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
>
> On 09/09/2019 18.53, Pengfei Li wrote:
> > On Mon, Sep 9, 2019 at 10:59 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> >>>   /*
> >>>    * kmalloc_info[] is to make slub_debug=,kmalloc-xx option work at boot time.
> >>>    * kmalloc_index() supports up to 2^26=64MB, so the final entry of the table is
> >>>    * kmalloc-67108864.
> >>>    */
> >>>   const struct kmalloc_info_struct kmalloc_info[] __initconst = {
> >>
> >> BTW should it really be an __initconst, when references to the names
> >> keep on living in kmem_cache structs? Isn't this for data that's
> >> discarded after init?
> >
> > You are right, I will remove __initconst in v2.
>
> No, __initconst is correct, and should be kept. The string literals
> which the .name pointers point to live in .rodata, and we're copying the
> values of these .name pointers. Nothing refers to something inside
> kmalloc_info[] after init. (It would be a whole different matter if
> struct kmalloc_info_struct consisted of { char name[NN]; unsigned int
> size; }).
>

Thank you for your comment. I will keep it in v3.

I did learn :)


> Rasmus

