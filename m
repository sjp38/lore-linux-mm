Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72740C31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D90520652
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:54:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WK8FGkjU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D90520652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD7F96B0006; Mon, 17 Jun 2019 12:53:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A88488E0002; Mon, 17 Jun 2019 12:53:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 928578E0001; Mon, 17 Jun 2019 12:53:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 575466B0006
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:53:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so865940pfq.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:53:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=5GIOr0j5QD0GGMq5iNvz4pmaxjrJeMOWrcA3ngAjb7A=;
        b=R4mrFXExEmJzvgSBCJN7xU9dGkapaaNtoB34uOPdxmboufzJ6bdE2IUYpugneG6RyQ
         rBYnB64pPOBoIg41onCtd7vLpjRcX6+bHEF/srMerT/yYN0cs++WDX/WkOiyCdi1OOxe
         Mv9z+OzGCjmXcUyI06+qnXEXgsxtFj7jz3CIwS0IS4oTsIzqiNDlsY75pTgrbLqzGWB0
         lpCDM54tJDE/uE9ssq3gcjp//h0St5to4EbmaVYgNFco6zvheAsycM1oYWypzoTchrYP
         FqgD8FukrVkY8nVg0b5x07z3VlXLUFYgLtTxja1SPyunkqVTek7LzTTCn8EtBKETAcEd
         QoLA==
X-Gm-Message-State: APjAAAURWdXPJLDfRAvswF3uCde8xo/M7iaGPP1V7/lqxV+af1mAH66H
	5HRNaIAESYJ+h69rRdxY/KRyldWqjF3aHL/3Ca4cbL4ArnkzAgoqCVL49J8qcA06nBzVMuyV9jr
	8JLEBQLTt68HpsIoAn6sGzTiLZiFYBJhCPj8lA6Wtk2WDODeYmBF/xX/snKL1xVedog==
X-Received: by 2002:a63:364f:: with SMTP id d76mr42138903pga.147.1560790438818;
        Mon, 17 Jun 2019 09:53:58 -0700 (PDT)
X-Received: by 2002:a63:364f:: with SMTP id d76mr42138860pga.147.1560790438126;
        Mon, 17 Jun 2019 09:53:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560790438; cv=none;
        d=google.com; s=arc-20160816;
        b=mYbUpn1c6DUZGzouOwuKVBn+jHd7CXR0Wg4JjsCHaddQFg3o5H/ZAmHNuBJDPFamzC
         fffByrMyjFngdR8jCAIBMeDS+23NANu++wQOhLF2rrGFZjrsLoEWvauWdeBLJppI82Pu
         iBUhuoXGeL1ryd8k7mxH6UkEpEA82lR7aoV7w7ahZ7f4jXgzy8q3d1YNxcBrbcLDGBRK
         h3KIidAJFEQJsf9xg6uWCkTZfjsVBFGDiaZsT16AaDZb9Sa/1/d2p3JwNAaflHoo60WZ
         exVHexlIyyu6ordl0VqUXJ+CG/Ii/G9g8NDnSoYXCK50O3uoA4Uk8X+h/ICtAsaK9Lnn
         uBzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=5GIOr0j5QD0GGMq5iNvz4pmaxjrJeMOWrcA3ngAjb7A=;
        b=QoIsh+Eh+95zhsjOV8pUUbGg96RqRdUEsQSXvBTZ7HyaoN+pafe2CPyCaO7nIGDwTa
         GVZggZyI+IaNozenOvCGgIvrV5oJaHGmTpA+uXdZh+Au1EmJ6L3pkjUEffFZIGmK2HIG
         oXhMN3cz8XNirAqZ5HIng5FDoLi8CXVBnWjF/d1UJgI//wZs/V25/V1XmulaMDMmWAN1
         PgjSRo0jEbiiwXLKOKN21qiV17KwDPKuuk8oDoUeIH4rvvbKJIsw820CKtUc7o1iWPcS
         BUlSqwdfLujUzJBDs77xzPNO6wJznDkcUnl+MfVJul6yQlKNMiLHiedxrkRcHywnxBOh
         a1CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WK8FGkjU;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor11587563pgg.30.2019.06.17.09.53.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 09:53:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WK8FGkjU;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=5GIOr0j5QD0GGMq5iNvz4pmaxjrJeMOWrcA3ngAjb7A=;
        b=WK8FGkjUVKq18qGzWscm8ahQHW1GUCF+ILUXe63ay3w9JUKolPUj+3YphhK0E8VUiO
         D3VHOeRgF69Os5dNYBD+3tBeL+QGWRxe4O1lUNffI+ciOxTZnQUOovBJ8QJgdVFafc4r
         vr9ia4ySytk0IJYT5noK89/yQrr24KTxwjB0P6wOHHrL6IXBMlSQnoyT65V9bcz8SQCW
         DT5wZDEmNGYbA9YuMMPBYvx3OLXoNdO+ZjLbq7Clkt9R8M322Au0gCU1XYbms5dQt9A3
         L+pOus4Fm3NyuNx6wxOGaBpjSeM0X2q/+qEIzrCnDdowFRbhBFU73gJDmUhuaF/pQcMj
         BBUA==
X-Google-Smtp-Source: APXvYqxQvlJR/5/Ch56UVr+neR0wtCeYjFoYvDMw4Dtm/ZsiOnsiu5rpaDFdeLO8KgOLgtgCCaiS3A==
X-Received: by 2002:a63:5211:: with SMTP id g17mr46491750pgb.405.1560790437276;
        Mon, 17 Jun 2019 09:53:57 -0700 (PDT)
Received: from [10.33.114.148] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id t14sm13687953pfl.62.2019.06.17.09.53.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 09:53:56 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
Date: Mon, 17 Jun 2019 09:53:54 -0700
Cc: Dave Hansen <dave.hansen@intel.com>,
 Alexander Graf <graf@amazon.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Marius Hillenbrand <mhillenb@amazon.de>,
 kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
Content-Transfer-Encoding: 7bit
Message-Id: <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
 <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
 <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
To: Andy Lutomirski <luto@kernel.org>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 17, 2019, at 9:14 AM, Andy Lutomirski <luto@kernel.org> wrote:
> 
> On Mon, Jun 17, 2019 at 9:09 AM Dave Hansen <dave.hansen@intel.com> wrote:
>> On 6/17/19 8:54 AM, Andy Lutomirski wrote:
>>>>> Would that mean that with Meltdown affected CPUs we open speculation
>>>>> attacks against the mmlocal memory from KVM user space?
>>>> Not necessarily.  There would likely be a _set_ of local PGDs.  We could
>>>> still have pair of PTI PGDs just like we do know, they'd just be a local
>>>> PGD pair.
>>> Unfortunately, this would mean that we need to sync twice as many
>>> top-level entries when we context switch.
>> 
>> Yeah, PTI sucks. :)
>> 
>> For anyone following along at home, I'm going to go off into crazy
>> per-cpu-pgds speculation mode now...  Feel free to stop reading now. :)
>> 
>> But, I was thinking we could get away with not doing this on _every_
>> context switch at least.  For instance, couldn't 'struct tlb_context'
>> have PGD pointer (or two with PTI) in addition to the TLB info?  That
>> way we only do the copying when we change the context.  Or does that tie
>> the implementation up too much with PCIDs?
> 
> Hmm, that seems entirely reasonable.  I think the nasty bit would be
> figuring out all the interactions with PV TLB flushing.  PV TLB
> flushes already don't play so well with PCID tracking, and this will
> make it worse.  We probably need to rewrite all that code regardless.

How is PCID (as you implemented) related to TLB flushing of kernel (not
user) PTEs? These kernel PTEs would be global, so they would be invalidated
from all the address-spaces using INVLPG, I presume. No?

Having said that, the fact that every hypervisor implements PV-TLB
completely differently might be unwarranted.

