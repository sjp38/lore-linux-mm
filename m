Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3A04C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:11:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B313421B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:11:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="lMU0YnL4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B313421B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3698E8E013D; Mon, 11 Feb 2019 14:11:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33C9B8E0134; Mon, 11 Feb 2019 14:11:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 206B48E013D; Mon, 11 Feb 2019 14:11:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB18D8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:11:02 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v16so1291wru.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:11:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=suWriVbdqLxuln4q3xrGkpt6191IAdBMzqwSuad7J9w=;
        b=DYXgKsEo7JN20pyGpr3465oT7enTv2rNhBYKIH0KlvfXZU0DsnUDdyg8SJT5nvNAAJ
         fYhQ6D4p1PfWPfwPeB5WtaJz5Dd9SfA8YcD4eZsinGCyRuGOUdGiFun1nGJVBeiwg0Xe
         l+Ku8J0gitJ+UaHkGnCRbKST6kJQ2O80YpMBwfaq7zleE1xprKrmEkpq9X18oaFuY+Xr
         UBuWqeCsva/mxVNkuv/HtaOeWy/XgGm6Upxx+wXwk6WVS8Z90+8gNoKn9vvLLEdmnaHQ
         FROQb4+kZt3ywGcAv6Lq0rVVe5wh/wet5XGtKtlDgdTojyyL6dweT+wykg3dffpEsrfj
         q4LA==
X-Gm-Message-State: AHQUAua4OTovHr1ouQVznQK82s7E8cdQQi2+E/qoRm7M7HPZCE6FCpxQ
	xLx/C3mT8V5eF4RGa7XxGcoNdh58Z502LIDzdrKw9i/u8gcqvL/Xwt3URIRJTRqoL68lUYNtHc5
	r/MoMZ7o6C46gDBTJN5B/al76xhjZ/NOJti1OY5Vvwdf7x1c4m2wrjL49pxeCXlnQ1Q==
X-Received: by 2002:adf:e98c:: with SMTP id h12mr8647090wrm.302.1549912262294;
        Mon, 11 Feb 2019 11:11:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdr1MP/d8Kt+NyyVTcE14GqYxGgFtRlPlM0RdGmWRB5f6DHHboSkRd14ModEpw9lSrLS1K
X-Received: by 2002:adf:e98c:: with SMTP id h12mr8647059wrm.302.1549912261640;
        Mon, 11 Feb 2019 11:11:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912261; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGKLXGPxxHGbsixSzls7X0bMtf6YVoPhq3Q+R/SoOlGLbsDXwK6t7O2XNEakqH1g9L
         mI/cqop4SOzhzkWehw2fnSVCCM78Hj2HmRb1bDkldnL4rX3kMUvBAg2LQc+3zRyGodY5
         5D4G0fAtKvcTM9AHyYKFysX7S4+ontrtm2KXNL3ey8fqhgUZ1O2sU/vbXsAA24eIKObr
         8QtUpUfvlgNr8waNwtoZhwhz79I2dwc8h8Ol1EydELMq/YKdWiVwehiUXU4DnqdQ5geU
         qO2/EB0PxuRZls5JgcAKNXvjqVA/3yRvDlU6EGp/490EdOlXE0eEmNCpD43G6zctLy3m
         wu0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=suWriVbdqLxuln4q3xrGkpt6191IAdBMzqwSuad7J9w=;
        b=WvGaz7dQwjEgxFn64nXJJI1bV2/Tp35delEaAGj4ml1SSONzneVNsrXDwoecq6Rzwh
         Xme9wssXbzkql4TV/U/3uGJ/VktfoOmvxyUaAmduTOhtOHMTFCnNE12KGagWiqPJr06J
         DpxnalX9Vs9ZBrvh17JzwCRQpcoEpEku7Ei1nsQLjF+/aHokDdTsIEm9XlEciqexgqhL
         JakUQTN8RO+LIx1bn7rd8G+XpnBrvDRLxab3dyiTPR64Wl8Y5U/sm3Rix2Z3VvA1A6qk
         6F/1XdlLj/mSFagVOw3FyS7El9jcBm/etIL9wxI4c1+VVdyJUHntu3ksxDgM+kjSE5BY
         XmxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=lMU0YnL4;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id l13si7614808wrp.224.2019.02.11.11.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:11:01 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=lMU0YnL4;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id E34D81EC01AF;
	Mon, 11 Feb 2019 20:11:00 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549912261;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=suWriVbdqLxuln4q3xrGkpt6191IAdBMzqwSuad7J9w=;
	b=lMU0YnL4Woztytt7TxuqJkyBPGg1CLMo98QyAqNKXGPXL/DQ0Vc3nPgg3EiO8DryJJLpEx
	9Aa2gH4CWJOti0bm12IQd0BpnOFaTLiX26ggB2qD5yKlcHfCZGufseOL2Sx5U0CSQMOXTA
	uCTnaxxTLbAcfRKtMGq8xg3a7sQOgwI=
Date: Mon, 11 Feb 2019 20:10:59 +0100
From: Borislav Petkov <bp@alien8.de>
To: Nadav Amit <nadav.amit@gmail.com>
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
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
Message-ID: <20190211191059.GR19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:09:25AM -0800, Nadav Amit wrote:
> It is just that I find the use of static_cpu_has()/boot_cpu_has() to be very
> inconsistent. I doubt that show_cpuinfo_misc(), copy_fpstate_to_sigframe(),
> or i915_memcpy_init_early() that use static_cpu_has() are any hotter than
> text_poke_early().

Would some beefing of the comment over it help?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

