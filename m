Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A142C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:15:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E473B20861
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:15:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KufUXcCH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E473B20861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6296B0006; Mon, 17 Jun 2019 20:15:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 656018E0005; Mon, 17 Jun 2019 20:15:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5448B8E0001; Mon, 17 Jun 2019 20:15:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDEC6B0006
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:15:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so6758046plo.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=J4ERNaAOi1Sm06NQyxiHs/joERhtwrCsfmkXb7NeUCI=;
        b=WYpHc9eMqPe/jgfARnu5ju049haJbNqPhyZaDBJxSktrdwlXGfTNc2mxw6Uij7+anv
         GVFR4Z6qkmXu9mNEfwZ5zEmMLRVQFJx0mIa/Fe5LAWAP5bzVp1dKeYi4+y9JwZoLeXjo
         1Lzow2lmeBMUY/UgbS40EdK8gy5UuKlkFcJ8WHXz4ls+MmBkzDJQbX1PGgm56V6Dvx4P
         vp5W21Mds6IKmydbBXDb2KRHcDZWFOgMwVD+FoTwci/5/45c1/lCtF61HiHLl24F9a50
         tCbEVsp4KIsaTHh8Fo+MZvAx7rb+V+LLbHo+BOueDJiAv22c8gYG3bR25FQbKUfzV8gS
         aTUw==
X-Gm-Message-State: APjAAAXlQv854BwHGIFD8W4p7gLybDLTjVyeOPSZ9kOTfANYKcMAKFBI
	Z8hkMvhdR+4f/MEOw5BQYfdzYGc9gizHCtP7zThQmkzUCVuI68zgf155qtiK0vW630ntaVsm4Fr
	K8QbKdTo5lF7WpokV1SATZpw4x20QJ3xeJuNRotJmwZ7vYyZ4EF3zby8eM4ySR+lcWw==
X-Received: by 2002:a17:902:9a84:: with SMTP id w4mr9208360plp.160.1560816918695;
        Mon, 17 Jun 2019 17:15:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYZ9UloD/e/8QDodlH1JmaQ57WXFakeyBeqIoLofLGWQ4xG1FL3eZ+iybNSzDbCvX8Gre4
X-Received: by 2002:a17:902:9a84:: with SMTP id w4mr9208305plp.160.1560816917932;
        Mon, 17 Jun 2019 17:15:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560816917; cv=none;
        d=google.com; s=arc-20160816;
        b=ahduEaaNuqjSOVEF2bqj9aBcRcnEbSpQtjqhrGUy7oWACksiEPoAauO/iEs+YkC9Dc
         2A7cQFf+y7nfKszBewF9n53go763Ly74pqGOKdIIsnfze8wOkAoJnCPELQqejJoZs9Cr
         qpIQY3e5mtZnIjGR2EoG2f6pmjg3r1Hkn+GjRAquV5vpSFjSLzWL5bNLID2kR9uNquB9
         IeztLc2/n7taGUhg5bsEyNnAAixQ5hgutj+wh8BcIVPcp09Ux9RhfNEVFlbBQ1nqM7PT
         Qi9BnxpvPma5qbyzdDOKZwyHjnuOq/M344FcwXlYOq6iMwrs/MPuRJn/jV7x+ostSe1y
         tfXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=J4ERNaAOi1Sm06NQyxiHs/joERhtwrCsfmkXb7NeUCI=;
        b=UKeQQ3kAWRJDGaopGmIh5KAUhZM2+j2yg6IAk01QNvRr42j3JQNqnd7RDZ9FhOoFlh
         W0uocUUmeir9y49Oi8IeLSQicGaYeH0K/Gl786nzLYxo+8OYGRJU83xUYbHO4bxMPAsA
         uNnzjJPBVqLxKMvlGKVNSaF5nMKcNnE4pqd6fEaEYuqCESNgEb7Ttkjw1zyCH/IRxWiY
         /y5Zl0CXaMdmCrwBDLYaDQA1YNii7vowsyfVXEu83wXN+KnrOEZZKXz7A5O4E9KtiBNU
         jVlCcP/5SOh0eeTiYHlBRQVGdso9Pvvu473BS5KVn+9uXa+PiALB1qdXikKz2EDmhZbP
         temg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KufUXcCH;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q8si12333516pfc.155.2019.06.17.17.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:15:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KufUXcCH;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 37C1E2147A
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:15:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560816917;
	bh=bQszpKKtRqay8BXy5xoZqczKSmcgkXxEdS7CWQ4wvic=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=KufUXcCHguV/MZBfdJ1UgPyRTW3eCKtSrfxLxy9i+UBAiIazGMrltN+iFYxFVl62s
	 IdEC552KDjlEdIDwV6nsWtxB0Hz2z7RrknFPD/knhdNuEJYm9q3wE83tea6VtQK6hq
	 voYk6nrOcb65/pVTvsckV8vOkNjw4TXXRvXpe+tA=
Received: by mail-wr1-f53.google.com with SMTP id x4so11912531wrt.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:15:17 -0700 (PDT)
X-Received: by 2002:adf:f28a:: with SMTP id k10mr11743806wro.343.1560816915741;
 Mon, 17 Jun 2019 17:15:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com>
In-Reply-To: <1560816342.5187.63.camel@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 17:15:04 -0700
X-Gmail-Original-Message-ID: <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
Message-ID: <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: Kai Huang <kai.huang@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, 
	David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, 
	Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, keyrings@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 5:05 PM Kai Huang <kai.huang@linux.intel.com> wrote:
>
> On Mon, 2019-06-17 at 12:12 -0700, Andy Lutomirski wrote:
> > On Mon, Jun 17, 2019 at 11:37 AM Dave Hansen <dave.hansen@intel.com> wrote:
> > >
> > > Tom Lendacky, could you take a look down in the message to the talk of
> > > SEV?  I want to make sure I'm not misrepresenting what it does today.
> > > ...
> > >
> > >
> > > > > I actually don't care all that much which one we end up with.  It's not
> > > > > like the extra syscall in the second options means much.
> > > >
> > > > The benefit of the second one is that, if sys_encrypt is absent, it
> > > > just works.  In the first model, programs need a fallback because
> > > > they'll segfault of mprotect_encrypt() gets ENOSYS.
> > >
> > > Well, by the time they get here, they would have already had to allocate
> > > and set up the encryption key.  I don't think this would really be the
> > > "normal" malloc() path, for instance.
> > >
> > > > >  How do we
> > > > > eventually stack it on top of persistent memory filesystems or Device
> > > > > DAX?
> > > >
> > > > How do we stack anonymous memory on top of persistent memory or Device
> > > > DAX?  I'm confused.
> > >
> > > If our interface to MKTME is:
> > >
> > >         fd = open("/dev/mktme");
> > >         ptr = mmap(fd);
> > >
> > > Then it's hard to combine with an interface which is:
> > >
> > >         fd = open("/dev/dax123");
> > >         ptr = mmap(fd);
> > >
> > > Where if we have something like mprotect() (or madvise() or something
> > > else taking pointer), we can just do:
> > >
> > >         fd = open("/dev/anything987");
> > >         ptr = mmap(fd);
> > >         sys_encrypt(ptr);
> >
> > I'm having a hard time imagining that ever working -- wouldn't it blow
> > up if someone did:
> >
> > fd = open("/dev/anything987");
> > ptr1 = mmap(fd);
> > ptr2 = mmap(fd);
> > sys_encrypt(ptr1);
> >
> > So I think it really has to be:
> > fd = open("/dev/anything987");
> > ioctl(fd, ENCRYPT_ME);
> > mmap(fd);
>
> This requires "/dev/anything987" to support ENCRYPT_ME ioctl, right?
>
> So to support NVDIMM (DAX), we need to add ENCRYPT_ME ioctl to DAX?

Yes and yes, or we do it with layers -- see below.

I don't see how we can credibly avoid this.  If we try to do MKTME
behind the DAX driver's back, aren't we going to end up with cache
coherence problems?

>
> >
> > But I really expect that the encryption of a DAX device will actually
> > be a block device setting and won't look like this at all.  It'll be
> > more like dm-crypt except without device mapper.
>
> Are you suggesting not to support MKTME for DAX, or adding MKTME support to dm-crypt?

I'm proposing exposing it by an interface that looks somewhat like
dm-crypt.  Either we could have a way to create a device layered on
top of the DAX devices that exposes a decrypted view or we add a way
to tell the DAX device to kindly use MKTME with such-and-such key.

If there is demand for a way to have an fscrypt-like thing on top of
DAX where different files use different keys, I suppose that could be
done too, but it will need filesystem or VFS help.

