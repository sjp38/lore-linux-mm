Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87937C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 16:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F51A2186A
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 16:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F51A2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D4928E0003; Wed, 27 Feb 2019 11:41:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 684D38E0001; Wed, 27 Feb 2019 11:41:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 574E48E0003; Wed, 27 Feb 2019 11:41:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25BEF8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 11:41:33 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id z64so7680269ywd.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:41:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jNzRPllHbXzBk5WYe7f3lRJ+kSXDkAC5RCs6HE5sl1c=;
        b=rh5kb0V8eCpmAlT/RlZabJKCsL8DEBUP6vzryYgWa7Z4uAG9vRgPIO0jRBBW3Z+eWk
         FMjcConpMRFkwpYmKh+hZ6zAGBkRp+wISvdFtL1sGF7Mcu/LL/mOniSj6sLzVHAhMYwN
         O10RR0bl5Gh30kkRD1rt7eksgaWYuJH+wLDQZMdwO/tvdaUDdFvP/mSjbxxmbK9TZLUd
         BYsS8w6QHt/ChMvhhFDc/V+rkejnN6cJBzNr2l5b81SCuKO6vHY83q8lkETSNfLhN6my
         X59BaredaXc2glH1o8to0OvYo2Nk53yyza2Qc7Yt3iLfC2Gjp15s9Mvr88L0VefVEe05
         VTHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ8HXRQvY509MOzq7t4MqoVIbawp1AeQK3jzB0kGPoPg6ot2wra
	oNFMZy/mV203h+otfCbjb5Virx0h0QEboesK63XAjobm3gaaV/4Gy89dr3Eq49y68IrJ5XU+XH3
	AhoL8VA6/lGTDuI6G+GckAWTdY6Yc/KbBqUAiGbNWtrd1N2PQ5SS+hoPCv9tgEHihvQUh/v/8pr
	ZX78wkJoJ+8dpOWJshp0R9IQyVNkXtV7FngSHx1S1fgvmOuMkEw76sm0/A1EkTy7WHbhU8q2FFX
	teSryHlDQ4Iv2V3dn7dLzymgoxTuG7oouTX/sT0yVmwTxCzTz1fWhoX1VaCse+6VY1uo02z/Lj0
	PTsrIVlxQj/KPIGUWG64N6ppPkpExRIdG5GNZIBOzT9oir5667oSetdqSmsXw7NIRpFHH24O5Q=
	=
X-Received: by 2002:a25:7085:: with SMTP id l127mr2764621ybc.369.1551285692752;
        Wed, 27 Feb 2019 08:41:32 -0800 (PST)
X-Received: by 2002:a25:7085:: with SMTP id l127mr2764527ybc.369.1551285691330;
        Wed, 27 Feb 2019 08:41:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551285691; cv=none;
        d=google.com; s=arc-20160816;
        b=udwyBVrm7dviUXJkYUcUZOQo/LpWAouzAQmSNAEjSPi4nVtDa+sXuVM40CnXqo5xDx
         zZeCESKDk31D3plIMjuxLLgsbNoc1NA3qkHhDj6ndr6++TwH2hXQfv7/CJcJXdgWdMaX
         dz9OaH0j5hnohLnr2CwPpFGJR/bLWtEjQIQf8CYx8uE8PmO5A9LLmcblAPwy3F9ti6RG
         ulYsibrRuge5hWsgdUhVCXFIgnWoechBkXQwfQmU9kfAIINTfVvsyQhGp743IZmAYSu2
         EzlRjIiqeGBXUkta/omEmNPQUmP6S/y1le7KInO20K/9EFwKFus374AAfCb+pPmPBYQh
         8Wwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jNzRPllHbXzBk5WYe7f3lRJ+kSXDkAC5RCs6HE5sl1c=;
        b=utnQD6Saa4GsLV40v/8nbvQm9XFKySzDIshLhsEfcZwBZD2rsziZtNQBUDKLTMMR4r
         i4BnroRfFeFiGEFlRlZ/pEyRkXpFEbRDNCl4CL9rTalYuPqdQ9pDr8R/nxeuW88T8rzA
         pUJ64vTr2f8wMFYZwvMbUptRqXJyJWy46RTB8c4CcxrT/oRiI5Uiw9rotp6aWHmsnzvD
         NzFLrel/NZnwEJ80/5CdcBEcMsgGkWKroy0M6R3b8I2lhLkFVd9+Bj9SfGpqzkt+2KO6
         xsQoxf0nqw/p1vTXopcW2836gcffsCqpf1PJcMLW3iFOPXGKSIpVzoAWwQy7s7lkeUAL
         en7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p62sor2002434yba.85.2019.02.27.08.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 08:41:31 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbKH3+fgAypoAZtrtfyFnKP+trAnXt2RuqX5SR1W3x9nJtUN9pQo4drfhvFOmUZDHM6j1W9Bw==
X-Received: by 2002:a25:b9c3:: with SMTP id y3mr2789679ybj.77.1551285690682;
        Wed, 27 Feb 2019 08:41:30 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::3:8416])
        by smtp.gmail.com with ESMTPSA id 142sm3762157ywl.31.2019.02.27.08.41.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 08:41:28 -0800 (PST)
Date: Wed, 27 Feb 2019 11:41:25 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Dennis Zhou <dennis@kernel.org>, Christopher Lameter <cl@linux.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 1/2] percpu: km: remove SMP check
Message-ID: <20190227164125.GA2379@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
 <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
 <20190226170339.GB47262@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB44814B3BA09388DFF3681E1388740@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB44814B3BA09388DFF3681E1388740@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 01:02:16PM +0000, Peng Fan wrote:
> Hi Dennis
> 
> > -----Original Message-----
> > From: Dennis Zhou [mailto:dennis@kernel.org]
> > Sent: 2019年2月27日 1:04
> > To: Christopher Lameter <cl@linux.com>
> > Cc: Peng Fan <peng.fan@nxp.com>; tj@kernel.org; linux-mm@kvack.org;
> > linux-kernel@vger.kernel.org; van.freenix@gmail.com
> > Subject: Re: [PATCH 1/2] percpu: km: remove SMP check
> > 
> > On Tue, Feb 26, 2019 at 03:16:44PM +0000, Christopher Lameter wrote:
> > > On Mon, 25 Feb 2019, Dennis Zhou wrote:
> > >
> > > > > @@ -27,7 +27,7 @@
> > > > >   *   chunk size is not aligned.  percpu-km code will whine about it.
> > > > >   */
> > > > >
> > > > > -#if defined(CONFIG_SMP) &&
> > > > > defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > > > > +#if defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > > > >  #error "contiguous percpu allocation is incompatible with paged first
> > chunk"
> > > > >  #endif
> > > > >
> > > > > --
> > > > > 2.16.4
> > > > >
> > > >
> > > > Hi,
> > > >
> > > > I think keeping CONFIG_SMP makes this easier to remember
> > > > dependencies rather than having to dig into the config. So this is a NACK
> > from me.
> > >
> > > But it simplifies the code and makes it easier to read.
> > >
> > >
> > 
> > I think the check isn't quite right after looking at it a little longer.
> > Looking at x86, I believe you can compile it with !SMP and
> > CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK will still be set. This should
> > still work because x86 has an MMU.
> 
> You are right, x86 could boots up with NEED_PER_CPU_PAGE_FIRST_CHUNK
> =y and SMP=n. Tested with qemu, info as below:
> 
> / # zcat /proc/config.gz | grep NEED_PER_CPU_KM
> CONFIG_NEED_PER_CPU_KM=y
> / # zcat /proc/config.gz | grep SMP
> CONFIG_BROKEN_ON_SMP=y
> # CONFIG_SMP is not set
> CONFIG_GENERIC_SMP_IDLE_THREAD=y
> / # zcat /proc/config.gz | grep NEED_PER_CPU_PAGE_FIRST_CHUNK
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> / # cat /proc/cpuinfo
> processor       : 0
> vendor_id       : AuthenticAMD
> cpu family      : 6
> model           : 6
> model name      : QEMU Virtual CPU version 2.5+
> stepping        : 3
> cpu MHz         : 3192.613
> cache size      : 512 KB
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx lm nopl cpuid pni cx16 hypervisor lahf_lm svm 3dnowprefetl
> bugs            : fxsave_leak sysret_ss_attrs spectre_v1 spectre_v2 spec_store_bypass
> bogomips        : 6385.22
> TLB size        : 1024 4K pages
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 42 bits physical, 48 bits virtual
> power management:
> 
> 
> But from the comments in this file:
> "
> * - CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK must not be defined.  It's
>  *   not compatible with PER_CPU_KM.  EMBED_FIRST_CHUNK should work
>  *   fine.
> "
> 
> I did not read into details why it is not allowed, but x86 could still work with KM
> and NEED_PER_CPU_PAGE_FIRST_CHUNK.
> 

The first chunk requires special handling on SMP to bring the static
variables into the percpu address space. On UP, identity mapping makes
static variables indistinguishable by aligning the percpu address space
and the virtual adress space. The percpu-km allocator allocates full
chunks at a time to deal with NOMMU archs. So the difference is if the
virtual address space is the same as the physical.

> > 
> > I think more correctly it would be something like below, but I don't have the
> > time to fully verify it right now.
> > 
> > Thanks,
> > Dennis
> > 
> > ---
> > diff --git a/mm/percpu-km.c b/mm/percpu-km.c index
> > 0f643dc2dc65..69ccad7d9807 100644
> > --- a/mm/percpu-km.c
> > +++ b/mm/percpu-km.c
> > @@ -27,7 +27,7 @@
> >   *   chunk size is not aligned.  percpu-km code will whine about it.
> >   */
> > 
> > -#if defined(CONFIG_SMP) &&
> > defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > +#if !defined(CONFIG_MMU) &&
> > +defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> >  #error "contiguous percpu allocation is incompatible with paged first chunk"
> >  #endif
> > 
> 
> Acked-by: Peng Fan <peng.fan@nxp.com>
> 
> Thanks,
> Peng

While this change may seem right to me. Verification would be to double
check other architectures too. x86 just happened to be a counter example
I had in mind. Unless someone reports this as being an issue or someone
takes the time to validate this more thoroughly than my cursory look.
I think the risk of this outweighs the benefit. This may be something I
fix in the future when I have more time. This would also involve making
sure the comments are consistent.

Thanks,
Dennis

