Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CD3DC49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB41B21479
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:53:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cc4AP0xR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB41B21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 632C66B0005; Mon,  9 Sep 2019 12:53:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2A56B0006; Mon,  9 Sep 2019 12:53:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D0956B0007; Mon,  9 Sep 2019 12:53:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 26BB66B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:53:59 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C73AA180AD802
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:53:58 +0000 (UTC)
X-FDA: 75915979356.02.shelf82_59909a4ca55e
X-HE-Tag: shelf82_59909a4ca55e
X-Filterd-Recvd-Size: 4104
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:53:58 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id x7so11043919oie.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 09:53:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ljPPuRHN7pv5RAsMzezY1X1Lrzb1YERDpsuR59TZXOI=;
        b=cc4AP0xRn0rgSFQQoweXYVeDmdpYDPSRo+ablACaZl0ulft5o6ThBhM8seUjI0P/As
         2FrOOiCIlbReGxyXmZp79zqy0714NmEYrwosquM4+F8/EVhQTv5G7t+8DHCw02YlvSGE
         lXv8RN6C8a9rDJ6KXPUD3o8PBc8qBShf0S/Zt4H06TQ9lIBXCuaIjnYRlgE556zpUafJ
         pJW1sBGoCv57FxGJeiL4qhoLSm0A6r9JOIHri2FMxlnPZfZX+K0V5FG4J7pGNZ4VcetG
         G3K8Dao7YimLUa59TVick6b/JNeGfMOsbkCaRTymi57XiU3kMmLtOBJb0mmhqL1UwMy+
         1jpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ljPPuRHN7pv5RAsMzezY1X1Lrzb1YERDpsuR59TZXOI=;
        b=A4dXi7seb7XoJ8j3sMayHs/FQAoYf5WOl5aMGZ9FdfbRYRDv0baPaRc7Lg1k9MgsJa
         BX6peN3eTG90sKLvHUbDf7sJm1RPf7d7mP8U8rtPujAP2HOYHIJlLnRBO3uBOXSo4We7
         GTDObJvziPDuSGvH9x1BUmnfiin6y4KT2hYZIxrL08c6xkBIDl2ZFc5AHoU72I3J3J/I
         6X1v2VLE0n7kdienjpTOaqeSumMC8oCmBAR7E77hRDflMUlEo9rK/DIOpZUFukGcevaN
         9xJEE2UXkxEnGw3AykgwVLHrmX0uMMOR49jpiWsDdH3xEO9tikWtxXukakvZo2g7IQv8
         G7Ag==
X-Gm-Message-State: APjAAAVlMIYUgYYiJQCjLVZNEXKB90DrHRSkLjk2/lh8/wVRAGKHADTv
	Ed40ThVX8wS6usqXhuAKLwHqWCHxgqpJiNxFF7Q=
X-Google-Smtp-Source: APXvYqwkg2PtS7tSU9ZYcfGxOf6NNnium6OK0+MhRkPbE2dXlTolFAlTYyAZJTz0MmnJAWGvVUW9zdVFOung1ms3nsY=
X-Received: by 2002:aca:4e97:: with SMTP id c145mr92531oib.145.1568048037621;
 Mon, 09 Sep 2019 09:53:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190903160430.1368-1-lpf.vector@gmail.com> <20190903160430.1368-2-lpf.vector@gmail.com>
 <4e9a237f-2370-0f55-34d2-1fbb9334bf88@suse.cz>
In-Reply-To: <4e9a237f-2370-0f55-34d2-1fbb9334bf88@suse.cz>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 10 Sep 2019 00:53:46 +0800
Message-ID: <CAD7_sbEwwqp_ONzYxPQfBDORH4g2Du=LKt=eWf+6SsLgtysBmA@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm, slab: Make kmalloc_info[] contain all types of names
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 10:59 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 9/3/19 6:04 PM, Pengfei Li wrote:
> > There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> > and KMALLOC_DMA.
> >
> > The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
> > but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
> > generated by kmalloc_cache_name().
> >
> > This patch predefines the names of all types of kmalloc to save
> > the time spent dynamically generating names.
>
> As I said, IMHO it's more useful that we don't need to allocate the
> names dynamically anymore, and it's simpler overall.
>

Thank you very much for your review.

> > Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> >   /*
> >    * kmalloc_info[] is to make slub_debug=,kmalloc-xx option work at boot time.
> >    * kmalloc_index() supports up to 2^26=64MB, so the final entry of the table is
> >    * kmalloc-67108864.
> >    */
> >   const struct kmalloc_info_struct kmalloc_info[] __initconst = {
>
> BTW should it really be an __initconst, when references to the names
> keep on living in kmem_cache structs? Isn't this for data that's
> discarded after init?

You are right, I will remove __initconst in v2.

