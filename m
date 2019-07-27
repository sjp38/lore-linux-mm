Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83570C7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 14:54:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21600208C0
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 14:54:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YJPTCKbr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21600208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EB008E0003; Sat, 27 Jul 2019 10:54:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89CB88E0002; Sat, 27 Jul 2019 10:54:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7638C8E0003; Sat, 27 Jul 2019 10:54:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4009C8E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 10:54:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so34849660pgh.11
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 07:54:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=D5XW4qPO7PG7qW1vC7+jzqiEcor7lsKHrWxRp6RkF2U=;
        b=cOCHbl3Cn5GIzx84RcQvDuJUf6mNf9UD3q/KL3QXUXqTAyVUQB/cLnFv1CxbxOp3j9
         /ojWuK/S8HC0RM05GaABaJSbucYvGwnRNzy1wIcnZsggVuJyfCFkJqXSowfGTCjyNjbE
         PsTb0ysq00g+QJYStKgnwinrq3YmMWAR37X9wpqnzFKmZsK2LzpqcIZOYU5mmIkZCmR8
         kPGoDHcQ6XRMSL4UXetA3x7MQ+4SYNCpmwO0An18OJ23hQPeAZjYekf6xuGT17QEQW7T
         8wiCte9oHSk8+V/VqqEkCzeFD6mTlpQF/un9mRDH7/gt8MHVxI9BQ/3pUhovXr1L65Jy
         /oZA==
X-Gm-Message-State: APjAAAUyPhDP5USJyxU7HzaSe5fHfAq9hFFicpZONv77hP3JBk712dV8
	Y711FwJb1LqCFP7SXomvVHaXnJj2XF/ct+WwmCMLSsTHjt57yW8VQO4EGcYMz8n90ub/dAZTnLv
	Orb8ob63OHzmmRtQfToteSq20cTlOTGK+MUnyB7RAkpCM5C44XFwaJ23Q2DV5D470Pg==
X-Received: by 2002:a62:cec4:: with SMTP id y187mr27478603pfg.84.1564239275927;
        Sat, 27 Jul 2019 07:54:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiwU+nB+MEFwyaQ8GOaoSs9t3h4ICu6wzt2VR8dlvgT1CDfankm9Zc8gFbOIPJghOwVUyx
X-Received: by 2002:a62:cec4:: with SMTP id y187mr27478569pfg.84.1564239275119;
        Sat, 27 Jul 2019 07:54:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564239275; cv=none;
        d=google.com; s=arc-20160816;
        b=ZWe7kVCb78y+Ncp+Xqf0S7ZQj3S4/iVB94xz0Fws1fCfwXOcRSQ7nX6GQndKnshmTo
         4cUFls8YiTcMCwFpqZCzC6zrhk/RGaRUotgq7CAkx/8dAbILpRavoEg2AMZrlvWAjWe7
         +lRCrAkyc79hCLdJHcYrsDe88GoN5fOYi8D8Hotthlz2F2KCpxa/MvS5SaXTWMMfN2KB
         tOk2ix0iCVo6cCgkODKXiBTfXROc4aw9LdRUvImbheDgetwP6Hy1GuH2rqYPWWWHZO5w
         3SjYY9CNPo3xI2k4MDqcQOH+COUiVLcVFWFiI8UlOsyXu4Ncl98nCcSsaFxvLt1b4r8r
         SgOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=D5XW4qPO7PG7qW1vC7+jzqiEcor7lsKHrWxRp6RkF2U=;
        b=gHJkc3lIgBSKdGeRZVqNg9HCO26wKBhbvv0PcxeuZtS8Ikor6xZhSjnlrIBlWz9B8y
         mNWdifCeFPp2s5UE/3BsDIJ1nRB8zQ7B3Ey8k3CP+eJIfYpf1EvyFbLQmQ2geOAXPHCZ
         wLF2lG1k7DfLP/KY4az1R9T6qwi1MBDc1MqCWJHqS6Gcrk1KjUNMlYmyIaRkExDYlIin
         8dqd0/Dx54QOziwJpI3LPL8WoiPFAQtCjR9hbl3crBelZDhIWiikEO/kcq85bz3BMDkI
         /TGfGnOLWEhjJX/rWfU3qCNO9nswV5MvC9UKk0I72k0r0KaCnz7Ncy723IwfI2HgmgMS
         r7bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YJPTCKbr;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e11si21364044pgt.119.2019.07.27.07.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jul 2019 07:54:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YJPTCKbr;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 85DFF2083B;
	Sat, 27 Jul 2019 14:54:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564239274;
	bh=OFml/XqGHlHC7b5jUffn+v4QUcYFkjegmPDDGqlHo8g=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=YJPTCKbr4Ms6+mTlfX3AzaUAsmqSPZePSXEInMcrDoOwcjVpVO4EoLNTTETt0KOW3
	 c/KexHE2kD7jkwbIDWjgMddLq5lxV5Ym0HGJW64ymZ/p4FT+x6aHnsY0i+n3ZF545d
	 OhRJRGj+wUQeaIYy/YurV2wMQqX++8u1BgZI1d98=
Message-ID: <b4d640c2cd65a87a380115aafb68b8b48df15788.camel@kernel.org>
Subject: Re: [PATCH] mm: Make kvfree safe to call
From: Jeff Layton <jlayton@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML
 <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Luis Henriques <lhenriques@suse.com>, Christoph Hellwig <hch@lst.de>,
 Carlos Maiolino <cmaiolino@redhat.com>
Date: Sat, 27 Jul 2019 10:54:32 -0400
In-Reply-To: <20190727003851.GJ30641@bombadil.infradead.org>
References: <20190726210137.23395-1-willy@infradead.org>
	 <CAKgT0UcMND12oZ1869howDjcbvRj+KwabaMuRk8bmLZPWbJWcg@mail.gmail.com>
	 <e4b0d323ed0bc159d863945251cf3f4c4064526c.camel@kernel.org>
	 <20190727003851.GJ30641@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 17:38 -0700, Matthew Wilcox wrote:
> On Fri, Jul 26, 2019 at 05:25:03PM -0400, Jeff Layton wrote:
> > On Fri, 2019-07-26 at 14:10 -0700, Alexander Duyck wrote:
> > > On Fri, Jul 26, 2019 at 2:01 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > > > 
> > > > Since vfree() can sleep, calling kvfree() from contexts where sleeping
> > > > is not permitted (eg holding a spinlock) is a bit of a lottery whether
> > > > it'll work.  Introduce kvfree_safe() for situations where we know we can
> > > > sleep, but make kvfree() safe by default.
> > > > 
> > > > Reported-by: Jeff Layton <jlayton@kernel.org>
> > > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > > Cc: Luis Henriques <lhenriques@suse.com>
> > > > Cc: Christoph Hellwig <hch@lst.de>
> > > > Cc: Carlos Maiolino <cmaiolino@redhat.com>
> > > > Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> > > 
> > > So you say you are adding kvfree_safe() in the patch description, but
> > > it looks like you are introducing kvfree_fast() below. Did something
> > > change and the patch description wasn't updated, or is this just the
> > > wrong description for this patch?
> 
> Oops, bad description.  Thanks, I'll fix it for v2.
> 
> > > > +/**
> > > > + * kvfree_fast() - Free memory.
> > > > + * @addr: Pointer to allocated memory.
> > > > + *
> > > > + * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
> > > > + * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
> > > > + * you are certain that you know which one to use.
> > > > + *
> > > > + * Context: Either preemptible task context or not-NMI interrupt.  Must not
> > > > + * hold a spinlock as it can sleep.
> > > > + */
> > > > +void kvfree_fast(const void *addr)
> > > > +{
> > > > +       might_sleep();
> > > > +
> > 
> >     might_sleep_if(!in_interrupt());
> > 
> > That's what vfree does anyway, so we might as well exempt the case where
> > you are.
> 
> True, but if we are in interrupt, then we may as well call kvfree() since
> it'll do the same thing, and this way the rules are clearer.
> 
> > > > +       if (is_vmalloc_addr(addr))
> > > > +               vfree(addr);
> > > > +       else
> > > > +               kfree(addr);
> > > > +}
> > > > +EXPORT_SYMBOL(kvfree_fast);
> > > > +
> > 
> > That said -- is this really useful?
> > 
> > The only way to know that this is safe is to know what sort of
> > allocation it is, and in that case you can just call kfree or vfree as
> > appropriate.
> 
> It's safe if you know you're not holding any spinlocks, for example ...
> 

Fair points all around. You can add:

    Reviewed-by: Jeff Layton <jlayton@kernel.org>

The only real question then is whether we'll incur any extra overhead
when some of these kvfree sites suddenly start queueing these up. One
would hope it wouldn't matter much on most workloads.


