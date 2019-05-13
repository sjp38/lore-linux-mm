Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9719DC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:15:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31869208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:15:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="REx4synB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31869208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A4686B027C; Mon, 13 May 2019 11:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8556C6B027D; Mon, 13 May 2019 11:15:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 743266B027E; Mon, 13 May 2019 11:15:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A44C6B027C
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:15:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e14so9354213pgg.12
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:15:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sYk1qF0Vg/KIRkZli5M/2CG/IiUILwRXwJH2skE3G4Y=;
        b=YqbAcDOPkdSzoP4pj2B18JoSNn65Zo5SflHmGu6xJMPjh852ddXt/c6QyXu4pfX7dT
         FLEJdpNkvB/q9V9P68uQ0wReXiabgfBG4xk2tn9SSivpv31fFV/TvjPBGkVRYewTX9eh
         Qhdd9xtEytsMZaGEBP7VVFIcuTrfiwifRV8CX2fQr3qRJSiP6u0ypcTq3CdxBQcQs7yc
         E4nh+k0j+I+C6folw0aKrv92fdbuWqNaAuIojFz+2p0KnKN0Fdp94FUkc3jsRcJoTQFV
         V6KS7IgSjlS3QaHR3VewN0LxVEWH1gqxP+ppn8QdYtunEyIiFFXUelhpLNWrzuyEnA4z
         hvpg==
X-Gm-Message-State: APjAAAXSI65EvrDEl5Ngf/IJFksPYlI+bvHevyvcvq0ZQUAMGZ0YkdGz
	PRm25lm9WKMfDOfdHND8u4XzyCvFE1iZ3f/DypcrNsiRC9OJ+aDTBq+DdSqq8zviBRHjvgtZ/66
	7DUrhoFXdRW/mD5W8MDbi58W1VQd8e26uniEEhZSCH5WtD2WaNhEt+vocikaj/30fmQ==
X-Received: by 2002:a17:902:694b:: with SMTP id k11mr31670946plt.307.1557760510642;
        Mon, 13 May 2019 08:15:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJY0sh2XWbU+FXDoUDt0Nga25btGEXGjCoCI2FxKvVcgPrOBo1YgaXCIemFe7Vn1neboWv
X-Received: by 2002:a17:902:694b:: with SMTP id k11mr31670830plt.307.1557760509801;
        Mon, 13 May 2019 08:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557760509; cv=none;
        d=google.com; s=arc-20160816;
        b=eAcEjsc+La/dBjAQyq51P8yJNplSxTOloli7sCgMzfxa6e0mKaBxnaNUrjwL7bNQt6
         kOMIHr81sNlnwu+ftLGQxKKYxD32Y+N0lKWncrppj586B2v9aXnD6ZOeCsTO+7vZ3pyE
         HKCgRIggAKXL9HD9+sTE+yGqMScg9fpBTePAnb3GLMOy1o11SxbSxN9pwSa8o9ssEMHK
         gw5cxJLsV2o53G89YKnUCYqTVZF5uvKe34PrFKT/ObMuppvAQkaiRogN2Wnonrvlb3Tt
         Jx+XkmgCA+kF8BCUstwUaamchZm1q/XM24EzcvEx5LsUpxSMuPIFADBANLRT10Ie43wm
         QPPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sYk1qF0Vg/KIRkZli5M/2CG/IiUILwRXwJH2skE3G4Y=;
        b=uQtgQIM2AYPAkHKwEDnZRCmCIzF8rFwjG353amYGH98yH972n+rSP+2ElaBrh/DNIa
         tlFH8bsN93YAkqlKpllGK3M7KEwMayIOe3ugosWR+icziRhsgB1xrIkVOQn2uRxss3RV
         dkYNGpyMRyFqUYrK9BFvX04q50OXjaBL9WLSIwRl8hltAZYpZDtJcLUWVYjrOgrXLI7x
         xeLuXkIYKxztwFo7DiNA+Lott66DE19Eeoxe2leSKS54GvIDmQO23BuE4ioDmxY5ji6x
         H9eUwvjKUqBxRH+ujHEZIn/xc4Tguz0ByntkD+lMNu5OHjDTHW/dwRUVKUVVOx3Q8CpE
         LnEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=REx4synB;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j20si1240928pgl.332.2019.05.13.08.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 08:15:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=REx4synB;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sYk1qF0Vg/KIRkZli5M/2CG/IiUILwRXwJH2skE3G4Y=; b=REx4synBpzyocaSPNSMhz/dBh
	x399vWJqF7p4npVM5QsVPsG55ErkZ5fQHzNE7SvhPaxAGuPAcMoqAhGfsgpUJo8i76muR4yWQQUtU
	tQxC2t4SmATs64p35q/UrMh+zG44Emo+gkoUbGpHChXki9LtyftxRMvXAnAt+8772zDazDPvmcrYZ
	IO6mWpHJHrpQ7Wh+tT7dtK938iXOpR30ImB4A7clcoQAjzmeyAiFIpojNXFvexY4vkFKlAG8lL58r
	+Sogz+Ndue92+0bFtoSM4dJkpK9Nw4F2bT0AXmKHBTkW2UkLKappwxdwuffjpqkmFrgkz4tA9Fal8
	/7i9i1OVQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQCfO-0005lL-4u; Mon, 13 May 2019 15:15:02 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 57CEA2029F877; Mon, 13 May 2019 17:15:00 +0200 (CEST)
Date: Mon, 13 May 2019 17:15:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
Message-ID: <20190513151500.GY2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 04:38:32PM +0200, Alexandre Chartre wrote:
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 46df4c6..317e105 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -33,6 +33,10 @@
>  #define CREATE_TRACE_POINTS
>  #include <asm/trace/exceptions.h>
>  
> +bool (*kvm_page_fault_handler)(struct pt_regs *regs, unsigned long error_code,
> +			       unsigned long address);
> +EXPORT_SYMBOL(kvm_page_fault_handler);

NAK NAK NAK NAK

This is one of the biggest anti-patterns around.

