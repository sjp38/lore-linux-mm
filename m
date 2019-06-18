Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A672C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:36:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BD3820673
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:36:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="u2mLIPKk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BD3820673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06B366B0005; Tue, 18 Jun 2019 12:36:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01C318E0003; Tue, 18 Jun 2019 12:36:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4CAB8E0001; Tue, 18 Jun 2019 12:36:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABBAF6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:36:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so10273256pgh.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:36:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=IL1nW/+YbqMLhSW1samVerTY8Tv4aXFIAsLDfQFzMZQ=;
        b=afXzvZc6LMabuUzCJLoyPtjzcsDdPp9HYQ4l4lEj44P77Vi+3p991O7A9d61MNbqxZ
         KB9hoz8BJqVIyaUrhRwM+9TXA2GOT0cRbJtwoCqf26SZs8xcP1RDDVLqxjTJ0CB/Hlz6
         DK2J8Skp5zoFoRgLVh09e1M44ndtB+gCOCcQwifrLZyNAY2r/M70E5SzUl7NbEeZuFeE
         FEqZtYQAlSVbmw447/6XN4xRhTFc3ZT1Tz9vLU03LGUCWZtqRrY5kFKfMUBaJDmORAes
         sdHv5OgKWPQIV69rAc4dQAINggdMwYzqwh2CVzocElqzxuGeZ/u92MS62GjWSxMu5edO
         ctdg==
X-Gm-Message-State: APjAAAWRYVf4+snrT3jL8u5V+Bu1PTzs2tQk4zSMYxlZmm2tKgchAE/O
	0K3zZzAsJk7DyyHDkf/sDPA3o4f+gsBON66ioGqVFg4DEt7ORUVomP20vutNANwIooBIw629yaJ
	0+4ylCN41remC27EZGToF1m6Eji0PJALLN8J6wtCrk8O1F06vjuNEu+QZb3i2hNO/2Q==
X-Received: by 2002:aa7:9a01:: with SMTP id w1mr96868123pfj.262.1560875801255;
        Tue, 18 Jun 2019 09:36:41 -0700 (PDT)
X-Received: by 2002:aa7:9a01:: with SMTP id w1mr96868070pfj.262.1560875800596;
        Tue, 18 Jun 2019 09:36:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560875800; cv=none;
        d=google.com; s=arc-20160816;
        b=NSgX6NrhYWiMFHe8zN1HU93LYa3NI9x8uzc3Pd0SXHBTQS07w83Xajvmxo32Vwoawx
         s77+INa+l3gy7Cz5j+7w57o24q/G1vsmMBQwU9eaqNz2myleLfhnVwV95Zunjtmc9aBI
         qguaeF8jfKAAOdLD+C46EONVLZQgBz3TZ+geiN/+Ju0+LlY1vPk2n9RVB6a7Nn1sduq2
         VAJ4A4HBcltOKX66Gzhq6S/1GogESEdK67nWfKaxHajztk4Zfynmnyotb/U+hZcK6iW2
         WyXXqlaKrplvL9yRd07J8qiVwhG411U2FFIA/DWbrnT0buY3jiAq86/b1GhnZpBVgD4f
         qtWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=IL1nW/+YbqMLhSW1samVerTY8Tv4aXFIAsLDfQFzMZQ=;
        b=mqz+GAxLuSEcfLrHF2a/auvcv12h4ZvMsF42hmrqyl3nZvgUvDASYnmhtfWcwFWv7C
         Hy/HxSx1u+tVTF0Qtk78OdLclSiOocMUrO3lfCELLKiluett8nkH4Jmpz/uHtNgfO0dO
         rEo8WCS0cJirZCTGUqFwO5RKQXlFE/gxIIm6kuzTlbE46NVtfns1EynT9EMNM6z41CZo
         kJE9XVkKNd87Ar+QqJ6kRNq3r6f1+fDLJV/RVv9elCwUj8xZCHKlByqYpK2BrK16+s7I
         Z/cM0SFMQ65cZ9+lXdsb+ljcZ85y8wDGfR5EuppvELTjpsqowHTj4mispg3Ob+YaMlcq
         ROqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=u2mLIPKk;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 35sor13933180pgn.16.2019.06.18.09.36.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 09:36:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=u2mLIPKk;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=IL1nW/+YbqMLhSW1samVerTY8Tv4aXFIAsLDfQFzMZQ=;
        b=u2mLIPKkGGTJlfOT8DyPvMbOrxkjRX35AmG/PHGn9N+8BTe14RT9Ij8iitPKyQLmFR
         wZSmx3Q4Z9agCYgcsZyxUI0L5UKzlAYSUUPFQBAyKt/WmYKvh2YXGAq6+/D85SQ39+d+
         b/vhEUVskV/SrzyR9tNTIBItPUHr4JjZT6lXrKC21zp8O1TD4sSwYFBlPVp1egY2xfk0
         5plXjFKxbsPmkNVUWhPTRXmWfqoQ8amD1yrULENsg1t2ngtBwwQjLekR8neR1u4UDu/L
         KWv71tTl1AC0zcA7z5Ig7Z5zxzE1/SP5ItTSUZ7V2PiHekbW+drpfBPQblCLwn+tIAjn
         ENZQ==
X-Google-Smtp-Source: APXvYqyQvU/+csIGlmtLO32PzNEQX2l+DPt+z+FAIRO0RdFTy04j53jWOmgqHKj+t/TS9lbmsrDlTA==
X-Received: by 2002:a63:e652:: with SMTP id p18mr3451756pgj.188.1560875800003;
        Tue, 18 Jun 2019 09:36:40 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:14b5:e5b0:c670:df13? ([2601:646:c200:1ef2:14b5:e5b0:c670:df13])
        by smtp.gmail.com with ESMTPSA id k4sm6458646pfk.42.2019.06.18.09.36.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:36:39 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <f701f859-0990-9f02-baa2-451dd6c8b3c4@intel.com>
Date: Tue, 18 Jun 2019 09:36:38 -0700
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Peter Zijlstra <peterz@infradead.org>,
 Kai Huang <kai.huang@linux.intel.com>, Andy Lutomirski <luto@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>,
 Linux-MM <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <8FDB1E33-21BC-400D-9051-7BE61400ACD2@amacapital.net>
References: <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com> <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com> <1560816342.5187.63.camel@linux.intel.com> <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com> <1560821746.5187.82.camel@linux.intel.com> <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com> <1560824611.5187.100.camel@linux.intel.com> <20190618091246.GM3436@hirez.programming.kicks-ass.net> <2ec26c05-7c57-d0e0-a628-94d581b96b63@intel.com> <20190618161502.jiuqhvs3wvnac5ow@box.shutemov.name> <f701f859-0990-9f02-baa2-451dd6c8b3c4@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 18, 2019, at 9:22 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 6/18/19 9:15 AM, Kirill A. Shutemov wrote:
>>> We'd need two rules:
>>> 1. A page must not be faulted into a VMA if the page's page_keyid()
>>>   is not consistent with the VMA's
>>> 2. Upon changing the VMA's KeyID, all underlying PTEs must either be
>>>   checked or zapped.
>>>=20
>>> If the rules are broken, we SIGBUS.  Andy's suggestion has the same
>>> basic requirements.  But, with his scheme, the error can be to the
>>> ioctl() instead of in the form of a SIGBUS.  I guess that makes the
>>> fuzzers' lives a bit easier.
>> I see a problem with the scheme: if we don't have a way to decide if the
>> key is right for the file, user without access to the right key is able t=
o
>> prevent legitimate user from accessing the file. Attacker just need read
>> access to the encrypted file to prevent any legitimate use to access it.
>=20
> I think you're bringing up a separate issue.
>=20
> We were talking about how you resolve a conflict when someone attempts
> to use two *different* keyids to decrypt the data in the API and what
> the resulting API interaction looks like.
>=20
> You're describing the situation where one of those is the wrong *key*
> (not keyid).  That's a subtly different scenario and requires different
> handling (or no handling IMNHO).

I think we=E2=80=99re quibbling over details before we look at the big quest=
ions:

Should MKTME+DAX encrypt the entire volume or should it encrypt individual f=
iles?  Or both?

If it encrypts individual files, should the fs be involved at all?  Should t=
here be metadata that can check whether a given key is the correct key?

If it encrypts individual files, is it even conceptually possible to avoid c=
orruption if the fs is not involved?  After all, many filesystems think that=
 they can move data blocks, compute checksums, journal data, etc.

I think Dave is right that there should at least be a somewhat credible prop=
osal for how this could fit together.

