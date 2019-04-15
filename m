Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E39CC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:06:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3FC42183F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:06:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kQC3glXM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3FC42183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 611486B0003; Mon, 15 Apr 2019 13:06:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BE936B0006; Mon, 15 Apr 2019 13:06:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B07C6B0007; Mon, 15 Apr 2019 13:06:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 123496B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:06:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f7so11642441plr.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:06:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BBzizg8bd/kFfxZxKYEBe2OceA+/lU/4tk1HQvVsa/M=;
        b=Jiq35GOVpmvSRRUg5hZPiw6s6VVjQGdMZEQ3B/4Q9GrAJX1KNz9Q7YOEYb+MUtDF/n
         kgfmQ3DwHCyoPy6q/7hcW5T77+z1qjnaD15pAJoEjDg6uftpcT+ahVahHUvMaHJFsq23
         MyVRFxg3TETyaf5t86nGc46coDE+2lekVqFEEjAP42sJmCUxwqE7qaVmPCPbx1KApVvQ
         l9+QF7RDh7Uwgbz/+V9u4+yyVmj1mzKphDKJ19KjimZH4gz9vZZTJosHyJUQIH7gFAnl
         gPNMEuIHItJhvUAinpAlhpkRgufKUrCfVpykS4zZhEsvngUS8SJ+vr4dsm3K2LM0e6cr
         iOgw==
X-Gm-Message-State: APjAAAUVAtXsS3Vxxt9RDfqy87vltR+4sNXbW22/gRjQFl5991UeV9AZ
	RWyfUonkzWgVYfasM3HlvPPSGoKfVCJU7vr9gl1LqFdXMpJSJ4WmAy41PLhz9Drs/TZ4INuYyt1
	qbfS8aR5W0WdzUZsAm3bM8AmJvsh4kjEY7EyuoCJSDg357RgqgJsg3Wh0/oKJ5XhgTw==
X-Received: by 2002:a17:902:e002:: with SMTP id ca2mr76907471plb.131.1555347969653;
        Mon, 15 Apr 2019 10:06:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqworQvUiUB79yfvtpT5R11FGEpjuv7Hxmb0/ZEVRzm5StH5ty3LNswJx83Shoi181mAM1y+
X-Received: by 2002:a17:902:e002:: with SMTP id ca2mr76907408plb.131.1555347968949;
        Mon, 15 Apr 2019 10:06:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555347968; cv=none;
        d=google.com; s=arc-20160816;
        b=qIPYLPaHP46mkLd3/hSOg1Mo3Qv5frXLMSG0DCdmvAfrLfL56UyxY1sUNluOrS5AgX
         FhvXgKAr2X7lAXqZZiEvA2z99+FIh5F4lPcAuWiHPxv0tQKUkOoOiNZou+qAgOmf1yxQ
         sv3F8x327S0f0DQfCW4j2Ne2Dh4bhLujDegmSMwtIsbeXleWLWxvVIgIsnWVcTL4Dqvb
         04/0cckUKRP5x/HTFnAVrzv9qFCovFouXAws/KtbBRwDe0q7A11+lpvSZ/QChCI6jNYl
         lNa+9ANYZ8M3rDlsH8pHHEiUM0rttXsQ6ESyThf4D9OVtr9Xno0bzwBwDXUsGd0/xcZd
         pYuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BBzizg8bd/kFfxZxKYEBe2OceA+/lU/4tk1HQvVsa/M=;
        b=HZVoCLrKB0H2tGwNLoQcu9N/7lgW8RyOPcuDCkpjK0KuAF/PHXXU2TAGMAt9YyHl2G
         xB6aDoNieSUNv6oGI8ufox831TUUsbHVMHe8qgA9AXtRLixcAkjCx7xSEPCADkSThE3C
         ZNkgT3baJJEJ2IV1vXYTNaPF4yEOfl5x22CAh5gxLsNPospMM/0R3SP2m96GV2GU7XW9
         coIFqTDgK1QKq5sIUukDMDb7H5Pzp3nbOzbeBCHMrmmgZUx3vUlCIKVzpTMK9byZf64U
         RCAgKFWxST2D209Qd0I8pkcQqNhjS425hiU95nry7GagoxMQp0itgd7DnZBEGBY43LBu
         tiEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kQC3glXM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j5si46390393pfi.166.2019.04.15.10.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:06:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kQC3glXM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5885A218FC
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:06:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555347968;
	bh=8AmWko7T1LjNiFsryfxCZUOlHYcmwEq5GAJP/6U+Kz0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=kQC3glXMim2s7wvWuoydokEwkg+lQbkink0wDxiIvInS4YEe6aPRUg85exchxBD0Y
	 vHtzSbEugrj8DGcg2SMRXGdxZ0hylUm7iohIIAXok3irFaUIhFFHGgCR8v/2qXSJgR
	 wsNB1X/BPhnapBDmemqR48LxQ+IFE3hCTSjVPDWs=
Received: by mail-wm1-f45.google.com with SMTP id n25so21413589wmk.4
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:06:08 -0700 (PDT)
X-Received: by 2002:a1c:99d5:: with SMTP id b204mr22454485wme.95.1555347966888;
 Mon, 15 Apr 2019 10:06:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble> <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
 <20190415161657.2zwboghblj5ducux@treble>
In-Reply-To: <20190415161657.2zwboghblj5ducux@treble>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 15 Apr 2019 10:05:55 -0700
X-Gmail-Original-Message-ID: <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
Message-ID: <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Sean Christopherson <sean.j.christopherson@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 9:17 AM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>
> On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
> > On Mon, 15 Apr 2019, Josh Poimboeuf wrote:
> > > On Mon, Apr 15, 2019 at 11:02:58AM +0200, Thomas Gleixner wrote:
> > > >   addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
> > > >
> > > > - if (size < 5 * sizeof(unsigned long))
> > > > + if (size < 5)
> > > >           return;
> > > >
> > > >   *addr++ = 0x12345678;
> > > >   *addr++ = caller;
> > > >   *addr++ = smp_processor_id();
> > > > - size -= 3 * sizeof(unsigned long);
> > > > + size -= 3;
> > > > +#ifdef CONFIG_STACKTRACE
> > > >   {
> > > > -         unsigned long *sptr = &caller;
> > > > -         unsigned long svalue;
> > > > -
> > > > -         while (!kstack_end(sptr)) {
> > > > -                 svalue = *sptr++;
> > > > -                 if (kernel_text_address(svalue)) {
> > > > -                         *addr++ = svalue;
> > > > -                         size -= sizeof(unsigned long);
> > > > -                         if (size <= sizeof(unsigned long))
> > > > -                                 break;
> > > > -                 }
> > > > -         }
> > > > +         struct stack_trace trace = {
> > > > +                 /* Leave one for the end marker below */
> > > > +                 .max_entries    = size - 1,
> > > > +                 .entries        = addr,
> > > > +                 .skip           = 3,
> > > > +         };
> > > >
> > > > +         save_stack_trace(&trace);
> > > > +         addr += trace.nr_entries;
> > > >   }
> > > > - *addr++ = 0x87654321;
> > > > +#endif
> > > > + *addr = 0x87654321;
> > >
> > > Looks like stack_trace.nr_entries isn't initialized?  (though this code
> > > gets eventually replaced by a later patch)
> >
> > struct initializer initialized the non mentioned fields to 0, if I'm not
> > totally mistaken.
>
> Hm, it seems you are correct.  And I thought I knew C.
>
> > > Who actually reads this stack trace?  I couldn't find a consumer.
> >
> > It's stored directly in the memory pointed to by @addr and that's the freed
> > cache memory. If that is used later (UAF) then the stack trace can be
> > printed to see where it was freed.
>
> Right... but who reads it?

That seems like a reasonable question.  After some grepping and some
git searching, it looks like there might not be any users.  I found
SLAB_STORE_USER, but that seems to be independent.

So maybe the whole mess should just be deleted.  If anyone ever
notices, they can re-add it better.

--Andy

