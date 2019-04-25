Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE6A3C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:48:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9F0520717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:48:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nvO/Luk1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9F0520717
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F8646B0003; Thu, 25 Apr 2019 16:48:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37EF56B0005; Thu, 25 Apr 2019 16:48:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21FA26B0006; Thu, 25 Apr 2019 16:48:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 011E76B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:48:24 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id w53so920050qtj.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:48:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7AlnxCGIjlH/KpFm0fw4ExsvnAh/aAKXQoDjEwnLD/w=;
        b=mhByGqf8HNZA8jrYlFydj6kq9cb2fF8+NFUjPhHI7X9ArkjEyJvmuZ3WQ6YazTvRsN
         pWIAzGd5Oe2uLltEKdjUnOCuxei+o+SPkZXSy0f0o4WUj4j/Gq0ucVgTo2oFgFMXZ6f+
         fvyxrvjEH5ifiaObtyL/PhkexPbYtriEJ+ucL/PzKnd0B5yvvMKrh4IhzOZsQheMoI+u
         odjfSnVy8LEVzIW82pKivpsOLucOptguYHZ5DdCtEnjg5upl33A1+vUnBO9IdikcDyyn
         tqRW2MFGwrwMVyVFRZ7u/644g7nxFX8TIAn2yYdV/PpbF//n1ZBX04oMtPicQrcFheCq
         JDQA==
X-Gm-Message-State: APjAAAUOsoS5xibUuuVkTp4jBjVnkKamUlf7k0/ah0Y2u8WOBUKLIdh+
	7S+IMb93vESrLJBPkOogdyW/SaipkCoFAnGW0fd8jsaGHtSrTDrKBbXgNLGNu0NSL+F0PlBt02N
	qDMrLdP4TpzQfJfoQvGaC2NY7Ku4gC+9oRX1mbLES/BuImhUZEtECefVCA9V39GdxlQ==
X-Received: by 2002:aed:3fee:: with SMTP id w43mr32953698qth.40.1556225303742;
        Thu, 25 Apr 2019 13:48:23 -0700 (PDT)
X-Received: by 2002:aed:3fee:: with SMTP id w43mr32953652qth.40.1556225303078;
        Thu, 25 Apr 2019 13:48:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556225303; cv=none;
        d=google.com; s=arc-20160816;
        b=zYC4bxicRPFa71jBt+M8PcZnRHLqB4wxK3YOtRcObJDBYx9J8zuPB3L2CMx7e+yUNy
         XifhBlaZEfsxm65reS5rtDA74Lm2malp3ejJgp13QJBD/kwlzPBJ3qLCdK1EfAbg7xaF
         4NqVaCH4Rz9iJq4R3p3EzYZltzy6jLep0fcA9NFiV296UWlEX8KhvuzTDfBqRWrAaKg+
         Ogc7LxDCsU/1KmOep9eJC4xpdtCSo2OKYcMss+mjG8eA8dUWrl+Q7MtquJiRuzYGQhLj
         Gs+O7FeyvbBIbw1US6oPZJAhlo0Zjf5NzQb/PPX/T2sd8ykWPWvSMZjdfxj/BQILT5GO
         YUrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7AlnxCGIjlH/KpFm0fw4ExsvnAh/aAKXQoDjEwnLD/w=;
        b=VrVxq6nAJhHVJkzZsO3NScWvwkYFVuQuAcIMfaFxuSyW8vjvOH0AYwR5N1vaF9JWfJ
         8fOryXsr0jX6USAw7wJjAWe8r8tlpsdufhUIMwz6nj+mBN2q5Ted8sbWLZMtbh642s4J
         ZBFY+O7N6ILhCW9CM2hb16Dc8+sSj70cwDNioBaZhl66ynZDbvoJ64+0X0F46kRq+8cs
         Na5U++R63tfcu4RFJU5/JyKADYG9DUBHUkKkP0fclQTKJWfMAmckLupDfERy/Bob5CFC
         mccb/lBDUDXapBOxEfkeZlJgWFP1Z9P4XJE1ligTqsostLXPXRzrPDKGQRTzI23l1a5F
         WDfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="nvO/Luk1";
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b18sor32405622qta.66.2019.04.25.13.48.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:48:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="nvO/Luk1";
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7AlnxCGIjlH/KpFm0fw4ExsvnAh/aAKXQoDjEwnLD/w=;
        b=nvO/Luk1xBiGvOryynLy6hbr7PLo9qTFTdr84ki7wcMCzEMz8Z16xWfNgArtT2I5W9
         jkpTFALxMZlRGFO4/6wwtfepEu3IA8RxZElxra0lOeIStmPNG0a9O0v/N8Qqt4St7snL
         pr9kZfuRaaVv+pRT3C7sKCmLxykXt3mzjj1zLjwkP2UCUA3IdD3mI9H8wZ+RRkDrVSu1
         iXAJba7aER90gTmjU4bQX+OMpsGVI994bLSqGIzbUkv1WeIP5zTTjTQw//HdOLZhw3wx
         nLgy/dvEzouejzd0eHsWP8aX2LYss8YH7lWK5k8AUsRRMe3j0x8h4An0G7CosiMx15Ci
         PllA==
X-Google-Smtp-Source: APXvYqxZxsQua8p9ane+xm1bSJUSycp6LE8vco6Y+xEs9KC9MJcAvtUBP9LPewiDPauyDtXT9gmTycxFopmsKMzIk9s=
X-Received: by 2002:aed:3b4a:: with SMTP id q10mr33419952qte.383.1556225302324;
 Thu, 25 Apr 2019 13:48:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx> <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
 <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
In-Reply-To: <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
From: Jonathan Adams <jwadams@google.com>
Date: Thu, 25 Apr 2019 13:47:46 -0700
Message-ID: <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
To: Paul Turner <pjt@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, Mike Rapoport <rppt@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It looks like the MM track isn't full, and I think this topic is an
important thing to discuss.

Cheers,
- Jonathan

On Sat, Feb 16, 2019 at 3:14 AM Paul Turner <pjt@google.com> wrote:
>
> I wanted to second the proposal for address space isolation.
>
> We have some new techniques to introduce her also, built around some new =
ideas using page-faults that we believe are interesting.
>
> To wit, page faults uniquely allow us to fork speculative and non-specula=
tive execution as we can control the retired path within the fault itself (=
which as it turns out, will obviously never be executed speculatively).
>
> This lets us provide isolation against variant1 gadgets, as well as guara=
ntee what data may or may not be cache present for the purposes of L1TF and=
 Meltdown mitigation.
>
> I'm not sure whether or not I'll be able to attend (I have a newborn and =
there's a lot of other scheduling I'm trying to work out).  But Jonathan Ad=
ams (cc'd) has been working on this and can speak to it.  We also have some=
 write-ups to publish independently of this.
>
> Thanks,
>
> - Paul
>
>> (Joint proposal with James Bottomley)
>>
>> Address space isolation has been used to protect the kernel from the
>> userspace and userspace programs from each other since the invention of
>> the virtual memory.
>>
>> Assuming that kernel bugs and therefore vulnerabilities are inevitable
>> it might be worth isolating parts of the kernel to minimize damage
>> that these vulnerabilities can cause.
>>
>> There is already ongoing work in a similar direction, like XPFO [1] and
>> temporary mappings proposed for the kernel text poking [2].
>>
>> We have several vague ideas how we can take this even further and make
>> different parts of kernel run in different address spaces:
>> * Remove most of the kernel mappings from the syscall entry and add a
>>   trampoline when the syscall processing needs to call the "core
>>   kernel".
>> * Make the parts of the kernel that execute in a namespace use their
>>   own mappings for the namespace private data
>> * Extend EXPORT_SYMBOL to include a trampoline so that the code
>>   running in modules won't map the entire kernel
>> * Execute BFP programs in a dedicated address space
>>
>> These are very general possible directions. We are exploring some of
>> them now to understand if the security value is worth the complexity
>> and the performance impact.
>>
>> We believe it would be helpful to discuss the general idea of address
>> space isolation inside the kernel, both from the technical aspect of
>> how it can be achieved simply and efficiently and from the isolation
>> aspect of what actual security guarantees it usefully provides.
>>
>> [1] https://lore.kernel.org/lkml/cover.1547153058.git.khalid.aziz@oracle=
.com/
>> [2] https://lore.kernel.org/lkml/20190129003422.9328-4-rick.p.edgecombe@=
intel.com/
>>
>> --
>> Sincerely yours,
>> Mike.

