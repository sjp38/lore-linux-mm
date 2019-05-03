Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FC98C04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:04:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6C132087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:04:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="LWBqwcXv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6C132087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EB836B0003; Fri,  3 May 2019 02:04:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 374526B0005; Fri,  3 May 2019 02:04:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EEBA6B0007; Fri,  3 May 2019 02:04:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2E276B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 02:04:42 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a16so2164329wrs.14
        for <linux-mm@kvack.org>; Thu, 02 May 2019 23:04:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=inhuVd3vZjvhqHNbAjisK/y3DxblsA0AtAJfAQHL6wY=;
        b=jx4dIT8lNur+4678uboQEjlJ3A//Y3ugJpaa5G/UEhf+cC9HDJEKsl/XmbozA6npnV
         Nm9a+8KVBhaLObZgtvhw4F/JpzMj/x4/jh8YJ5/ypFPmyMIJapJdqLbrlgw/PiN+eOuk
         7lM/l37WTsA7hnDWQ/3XXz/1vgN9O18UWNDF6WrSQjnNhIv8X8haKpB3O63eGnkLHq43
         0FiqsSsYBFEJuIE5fKFMNQU1dADMefQweF5O5xmHq/USBASkzq4JtOl/durcOb8FlSL7
         omImG+Y0kTLSukresZ/NtM2vMyz5sj1DtRdXzdbtL7GREWcXTyA1qUaUalq/lZaaxiRY
         fSEw==
X-Gm-Message-State: APjAAAXmsA/fL8mz6n44ioCfuSvyngqhHsp6EsmBMWTQ6ZbalQCUHkR5
	xl+zVH1n5pQRy15yACULYGfiFmwU2oucvirem5mkO11XgJmMBHWY2/lL11w5+wDluUTjbPvyRd4
	xRtdxgqRI54446mDqA5phDJ+x3bxInMxmyHGkj8+A7PPtP3q+bo8z47qc2YnUF7CYNw==
X-Received: by 2002:a1c:7e8a:: with SMTP id z132mr4905782wmc.92.1556863482204;
        Thu, 02 May 2019 23:04:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQLbHxk0RficfYtObdUkOLlI1dgF57Xw4ojptfbzom9wpnUCvr6CyBlUobZ0xPcDQKUEvX
X-Received: by 2002:a1c:7e8a:: with SMTP id z132mr4905724wmc.92.1556863481127;
        Thu, 02 May 2019 23:04:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556863481; cv=none;
        d=google.com; s=arc-20160816;
        b=zC1CaAhdeGEp8AqGaCGCF5HCj42tkJYYUKsKQ/3QfK1FFXZ4T7Z+2MWYU3hwQpQ9U/
         u3qfoYA+cqnw2GaNV6ezd68ems9IKVeskXzuM/E+yqO0+koaaSyeFJZoHvowTHC0fRtM
         FiPZwZ2/Le2kiV3+s9wanCfPLXBAYJs5+9hFYATccKMqmaBeTd3L/foGAuh7maLMWhA2
         q/HOQuwGLlIgAIzuxnEOcb7gDlAvcRRMLi+75xfTCjkNveah8KZ5wvEfDWmTwUasSOMf
         STPc3Xdw1tiCnAsQpTV9/YrCcoYefSPrw2LTYwZjFPWfn2f1XhiLfHG+Mhv+hUKekfri
         5m6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=inhuVd3vZjvhqHNbAjisK/y3DxblsA0AtAJfAQHL6wY=;
        b=b97IB9glk9JrMadDbBqDTMv6PbMVt0FgERlyFHui0NxyE87xG8nUS3eSKdfKsQ4WAl
         Xb3dtRh9DB/YvArN/6UNRTh23m3sH5Mlbeyl5qEZPWTJo+DdRNnCelvMDzM1FNWNV7/v
         OUIntiOYL8FP1ExeZssc7NjNfYaO5nVPHh+N0WXCcoWv8jROGGAMydwWaY/aLX2qHs9f
         Q0DUr1DzuUqIGmgvNLP10DAyhU8wtzlHkEWT7CPqMdMjVIso8VK7YT7n8/IrPRHYMb7k
         yZ43eAsLxEfuuXdnJKer+O2M0Ml/SABAwBCXN+o4heOmR2nUDJNvH+UnczLiKuUzLvsa
         LIHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=LWBqwcXv;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id n1si707366wmh.54.2019.05.02.23.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 23:04:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=LWBqwcXv;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2F0CA900008324B911E5A0D4.dip0.t-ipconnect.de [IPv6:2003:ec:2f0c:a900:83:24b9:11e5:a0d4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 44C2D1EC021C;
	Fri,  3 May 2019 08:04:40 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1556863480;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=inhuVd3vZjvhqHNbAjisK/y3DxblsA0AtAJfAQHL6wY=;
	b=LWBqwcXv9TxeGVJfuHnoYJt4sqkTr7VVVhHNMyx5iK2Pp0b4fFwnSb2ta85AKFQS+CGV4P
	sGY3VwB4eYteovGIFxohQFOjjiRgY+EHapLAbgfpfypBhBTbAnlSq1GV5+E4IpuBDovpYP
	F0grqmko7eCr2FvytGsB4zlH7gVYyBA=
Date: Fri, 3 May 2019 08:04:34 +0200
From: Borislav Petkov <bp@alien8.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Qian Cai <cai@lca.pw>, dave.hansen@intel.com, tglx@linutronix.de,
	x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	luto@amacapital.net, hpa@zytor.com, mingo@kernel.org
Subject: Re: [PATCH v2] x86/fpu: Fault-in user stack if
 copy_fpstate_to_sigframe() fails
Message-ID: <20190503060434.GA5020@zn.tnic>
References: <1556657902.6132.13.camel@lca.pw>
 <20190501082312.GA3908@zn.tnic>
 <20190502171139.mqtegctsg35cir2e@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190502171139.mqtegctsg35cir2e@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 07:11:39PM +0200, Sebastian Andrzej Siewior wrote:
> In the compacted form, XSAVES may save only the XMM+SSE state but skip
> FP (x87 state).
> 
> This is denoted by header->xfeatures = 6. The fastpath
> (copy_fpregs_to_sigframe()) does that but _also_ initialises the FP
> state (cwd to 0x37f, mxcsr as we do, remaining fields to 0).
> 
> The slowpath (copy_xstate_to_user()) leaves most of the FP
> state untouched. Only mxcsr and mxcsr_flags are set due to
> xfeatures_mxcsr_quirk(). Now that XFEATURE_MASK_FP is set
> unconditionally, see
> 
>   04944b793e18 ("x86: xsave: set FP, SSE bits in the xsave header in the user sigcontext"),
> 
> on return from the signal, random garbage is loaded as the FP state.
> 
> Instead of utilizing copy_xstate_to_user(), fault-in the user memory
> and retry the fast path. Ideally, the fast path succeeds on the second
> attempt but may be retried again if the memory is swapped out due
> to memory pressure. If the user memory can not be faulted-in then
> get_user_pages() returns an error so we don't loop forever.
> 
> Fault in memory via get_user_pages_unlocked() so
> copy_fpregs_to_sigframe() succeeds without a fault.
> 
> Fixes: 69277c98f5eef ("x86/fpu: Always store the registers in copy_fpstate_to_sigframe()")
> Reported-by: Kurt Kanzenbach <kurt.kanzenbach@linutronix.de>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> v1…v2:
>    - s/get_user_pages()/get_user_pages_unlocked()/
>    - merge cleanups
> 
> I'm posting this all-in-one fix up replacing the original patch so we
> don't have a merge window with known bugs (that is the one that the
> patch was going the fix and the KASAN fallout that it introduced).
> 
>  arch/x86/kernel/fpu/signal.c | 31 +++++++++++++++----------------
>  1 file changed, 15 insertions(+), 16 deletions(-)

Queued to tip:WIP.x86/fpu for some hammering ontop ...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

