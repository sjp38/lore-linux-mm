Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BAC8C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 14:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5C042083B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 14:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="AtSkMjV3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5C042083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D76C8E0046; Mon,  4 Feb 2019 09:28:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 388458E001C; Mon,  4 Feb 2019 09:28:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29F198E0046; Mon,  4 Feb 2019 09:28:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAFDD8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 09:28:42 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id q18so19546wrx.0
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 06:28:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7QWaSI9Kzgqtb8SEtCk6Q1g3OhoIUSGko6l3DVOvT7k=;
        b=qPSfoIqSmGT5TqGYcaeUm8kw3Uhw81/8QCZoW8Lp/HqYk13Nupt+VPtEEIF0Gwlefl
         zKilVFoo4inADqqfzz5gBpVK9WfUeoU14X7Z0DO/A33yzRQjkFtPq4lJqGRdTsNol9ob
         I6rZcQIz/FB0SsIPMENqWPIe4OlwOtPZA+kcXY1sSJhL55in0wEKRKJ3emxwPon6+0YE
         MhLssFR1KaqIGZ01y0Hy4sl0QZPZr3BVg7lG1dX8ja5NOwe+/TDXD7ZU80BcD8RdDNgy
         gY9a6lMDebG7tAXGuKZGVaq1lA4A8hSviptlVzqzB8ZPRzNboiqOLIGOZ0mDvXckrliZ
         +Lkg==
X-Gm-Message-State: AHQUAuZ1h1h4TezkckmVuPMW2ISC9J2rLztMwiL3VNvmBIAR9ZO7lAOv
	jACgFDCVx2uiPIdtBov2jrWFQ35NLBpZHDcb2SYi+8PFqZaa98rBXTW1dN+V7kT2EzdD/t89hlU
	c01KJFzbs1dmk3VlPUbpGYCPRe7jrPYQh1NsWNjRFTc+b21iejLQYADgi1x7J96GcVw==
X-Received: by 2002:a7b:cf0f:: with SMTP id l15mr14459969wmg.30.1549290522208;
        Mon, 04 Feb 2019 06:28:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFPG3785SlySY6leN4w6RGkoPSCkN6ATGFj/ZVPptEKo91ByjAxPdnwIOtVlvaWKyhwKEX
X-Received: by 2002:a7b:cf0f:: with SMTP id l15mr14459904wmg.30.1549290521243;
        Mon, 04 Feb 2019 06:28:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549290521; cv=none;
        d=google.com; s=arc-20160816;
        b=MroedohY1UY1kNz39ed8Z3FECLlg8g0qIIXA6ACif4sLQh3V/tLRLsb6iNDjDabmWx
         nVeyQ15YzNA1erQmLQv6Uq5y0UBRCqPNFhzfdQV7Xe1G1LTC7R8LvCbQT4Hzb4LvMOgO
         4DCLhDhEfYyk+eOKFpPHH2ROnZUlGMwOfAsm5i5NhHVxj/f18QPl96O4BGcy4gWh+uv4
         tvDQKlylWBaqK7bSfpHoGfCro9Gh+ykMmiCtJF4RB4m3GIBa4zggnRsqkorD+wtgNwDx
         MX1x1/UQSP8gd0uZW9RoL9oNJ40SYE/Z2vazoVXWv3mqV3mFC7nkfwJd1lCOOMWVEHng
         SsJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=7QWaSI9Kzgqtb8SEtCk6Q1g3OhoIUSGko6l3DVOvT7k=;
        b=IMLj+OTsuQP5eUkIeh8a2KAOK1Sa3J5vsqWiM4EZuBx9brRNC05/S+bRzhCbmyi/bM
         zQd5Cyk3YyejiuV2Lj+nYq6LSbK7VTaICR8bYyhd1d9f4qJNq4/LnE8MZFEWMdG+o6QZ
         o8dPszqKBZzJpMaQZ2LSSEcgR4tP178EjCFZglCfLyDCFM8GhKHO8aMKqWl2v++o2Prq
         cDpMELC3MvvSW4CqetuNwf1VXVZLaZW/98uYoUvfwD1sj6MdA0FsWoc3c7zR3UEwYsE0
         PINdmABxB8Q4rK/ZWIQh+V0e1EXIOog1zYEug2aUibKQe6eH77jGSdv1jZ3nLE5kM2wX
         3fjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=AtSkMjV3;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id u133si7565061wmb.182.2019.02.04.06.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 06:28:41 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=AtSkMjV3;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC6E200586F742EFBEF042E.dip0.t-ipconnect.de [IPv6:2003:ec:2bc6:e200:586f:742e:fbef:42e])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 196921EC014B;
	Mon,  4 Feb 2019 15:28:40 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549290520;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=7QWaSI9Kzgqtb8SEtCk6Q1g3OhoIUSGko6l3DVOvT7k=;
	b=AtSkMjV3V26u12tYepdjk6o9U9Pk4aRuwarM6f5IGq/OIK+z2V5XsIvRa2phDllI9Zpd8B
	uuiWlDwk5b69HGShQwpAEW34F3RmpjU/s2F8unqxcQyun4nUQo17fsPzOF7AfXDbkRf0qc
	sHuQzSqsCV3rWSo/aGkNjUr+0YORPEg=
Date: Mon, 4 Feb 2019 15:28:29 +0100
From: Borislav Petkov <bp@alien8.de>
To: Nadav Amit <namit@vmware.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Damian Tometzki <linux_dti@icloud.com>,
	linux-integrity <linux-integrity@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	"Dock, Deneen T" <deneen.t.dock@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v2 03/20] x86/mm: temporary mm struct
Message-ID: <20190204142829.GD29639@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-4-rick.p.edgecombe@intel.com>
 <20190131112948.GE6749@zn.tnic>
 <C481E605-E19A-4EA6-AB9A-6FF4229789E0@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <C481E605-E19A-4EA6-AB9A-6FF4229789E0@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 10:19:54PM +0000, Nadav Amit wrote:
> Having a different struct can prevent the misuse of using mm_structs in
> unuse_temporary_mm() that were not “used” using use_temporary_mm. The
> typedef, I presume, can deter users from starting to play with the internal
> “private” fields.

Ok, makes sense.

> > That prev.prev below looks unnecessary, instead of just using prev.
> > 
> >> +	struct mm_struct *prev;
> > 
> > Why "prev”?
> 
> This is obviously the previous active mm. Feel free to suggest an
> alternative name.

Well, when I look at the typedef I'm wondering why is it called "prev"
but I guess this is to mean that it will be saving the previously used
mm, so ack.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

