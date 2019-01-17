Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA4BAC43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 20:27:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67BAE20855
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 20:27:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VUH+HZ7S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67BAE20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 026138E0003; Thu, 17 Jan 2019 15:27:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F16528E0002; Thu, 17 Jan 2019 15:27:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2C2F8E0003; Thu, 17 Jan 2019 15:27:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A20138E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:27:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so8236143pfj.4
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:27:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Uif7NnSu4vC2FTPS4CEUaEq8UvXBfqUFaj2BoIL8DCM=;
        b=rJk9x7BbHo6CmrnEoUTozAs2vO5XaIKeNbPT9oOVVegtlY2anQBCAQLHZnMKERLfyK
         hat3cE+KyA+YEEGFFFtQ6nFhRkLFk/wx5/giNleReGqRHrQKYZM605dXyGsHuYxTTWAK
         SN4MfKCD81BtrCCqL3FTAt0cSM8qwwkF+qNurppaipGWIkX2HNzR6yE9TUSWib4j1P4u
         cx1zefPshNpOdY1cSgYgPwhUFlg5TEbB8t3xRjvDIPvn4rglZfcVa4aQhFHSUhbzK4EW
         alZPpSoRsA+afuNrgyrin1qyLitutr9zUtDMv9trH09BDS2VFhRn/Vq3bSBMyYVOHqvW
         RAyw==
X-Gm-Message-State: AJcUuke+8NcY+GO6TgkzeWWiEuvzgELRPZeDl426A9B4KQm41yxyTdWZ
	shjRAxrYrL2/jErC5mopBLh/1BJteePXDJpdTFQWQ15pWmsAJb90dOAgcmMh0wIYp7EfJym/jN+
	V1+cmqp4ZtCfDgiFjjWVj7pkCqnXxf/1TH1B3k+k9VFxlycGxeayn/TTnJ/ujaQH8KQ==
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr16105301plv.43.1547756858095;
        Thu, 17 Jan 2019 12:27:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7R1EMbcUrPYxmcFe8XSESPgK2wZZC5iV2ft1zp30gAGdfu6c3FnNTPsS7Ha/lLWwfgJocA
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr16105256plv.43.1547756857264;
        Thu, 17 Jan 2019 12:27:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547756857; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsE7bM9JXrohEcelbnmEFBFjeN2QW36+Nx4w2wdANlYQd2XcCvxRek2sOCNdEaclTH
         tRtONBoO9InEPX6pJ0KP6NIfinciVax6aT+O4B6YNkaVQcPdYo1QWJXiLkwwvra2Os7y
         BxoVgwKHrOme6ohcUUaNSuK2gHWsjCJwcAw5raA6SC3eq65kHMwGk9wfLX2xRYNPo6So
         9RYvYaEPNxMqX9Cw8ybfroqWvYrES0hKjwL/2ezBMW6Jjqu1SKC+nyZkwFLzi8zJtHVQ
         xiVlsXVj31xSdzhd3ZbKQhDH/NOdPUwr4KtaaF0ENKyWBUWeGApTDZ3xmmXlJwy/kPrf
         3RDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Uif7NnSu4vC2FTPS4CEUaEq8UvXBfqUFaj2BoIL8DCM=;
        b=O5boEvDegvsgT9nrh+WhHzAgCre3srlyJBxobg2YMFNuVhQ0B6ajDbK4uV2kLjXcwN
         swsxUnrBxZlCwtmy7iaTBAy3r1BtY0vH3xC8mFWfPll5c0KwzkvtYJrTb2UhfbQeZMwr
         RkFIQ15tnKh3FfMGlnhsqRGgGVwj8kSHsRXX4wwTz0oYNIhbFAO512LJp5UnLiSue4nt
         BVpvkDFHxw4WnRsiKIWL1DUIvKJb1hTEV8RPLCI1LeTza3wO8+lDSHWzWh3bJ7Opb14u
         5fReBJ40AjsaX8O6YDmNtWNqFNkQE9Mr/avdnCSqcsgPa1FipTg6oj3+RNJdCG4U9bMr
         YYag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VUH+HZ7S;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l81si2650671pfj.230.2019.01.17.12.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 12:27:37 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VUH+HZ7S;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A299620868
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:27:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547756856;
	bh=2LN0b2pEyZcmNHx/q/HSwUHJ+OFapnXo/7ZJjzZgSMI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=VUH+HZ7SOB7X5LEvHo3Ph2+FtFMu7dhVTyL7Ph8TKe30P2PxjCxurA2wcXYSM4OJz
	 9Ak8f8+hz6sqSOwkqKTU1meEoAmQ1xME1Pl982LD2lhv+4tEvX3HFjMxeA66BBPeW5
	 GB9wglXGmY+7w2R6zabIucXC4Kty3bi447vJGDKA=
Received: by mail-wm1-f53.google.com with SMTP id d15so2442499wmb.3
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:27:36 -0800 (PST)
X-Received: by 2002:a7b:c7c7:: with SMTP id z7mr14010272wmk.74.1547756855114;
 Thu, 17 Jan 2019 12:27:35 -0800 (PST)
MIME-Version: 1.0
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com> <20190117003259.23141-7-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-7-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 17 Jan 2019 12:27:23 -0800
X-Gmail-Original-Message-ID: <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
Message-ID:
 <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
Subject: Re: [PATCH 06/17] x86/alternative: use temporary mm for text poking
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, 
	Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, 
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, 
	Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117202723.ry6MPrly9_gYumCBpaqrwsYM6omb9oo5MjUCluX1icw@z>

On Wed, Jan 16, 2019 at 4:33 PM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
>
> From: Nadav Amit <namit@vmware.com>
>
> text_poke() can potentially compromise the security as it sets temporary
> PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
> from other cores accidentally or maliciously, if an attacker gains the
> ability to write onto kernel memory.

i think this may be sufficient, but barely.

> +       pte_clear(poking_mm, poking_addr, ptep);
> +
> +       /*
> +        * __flush_tlb_one_user() performs a redundant TLB flush when PTI is on,
> +        * as it also flushes the corresponding "user" address spaces, which
> +        * does not exist.
> +        *
> +        * Poking, however, is already very inefficient since it does not try to
> +        * batch updates, so we ignore this problem for the time being.
> +        *
> +        * Since the PTEs do not exist in other kernel address-spaces, we do
> +        * not use __flush_tlb_one_kernel(), which when PTI is on would cause
> +        * more unwarranted TLB flushes.
> +        *
> +        * There is a slight anomaly here: the PTE is a supervisor-only and
> +        * (potentially) global and we use __flush_tlb_one_user() but this
> +        * should be fine.
> +        */
> +       __flush_tlb_one_user(poking_addr);
> +       if (cross_page_boundary) {
> +               pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep + 1);
> +               __flush_tlb_one_user(poking_addr + PAGE_SIZE);
> +       }

In principle, another CPU could still have the old translation.  Your
mutex probably makes this impossible, but it makes me nervous.
Ideally you'd use flush_tlb_mm_range(), but I guess you can't do that
with IRQs off.  Hmm.  I think you should add an inc_mm_tlb_gen() here.
Arguably, if you did that, you could omit the flushes, but maybe
that's silly.

If we start getting new users of use_temporary_mm(), we should give
some serious thought to the SMP semantics.

Also, you're using PAGE_KERNEL.  Please tell me that the global bit
isn't set in there.

--Andy

