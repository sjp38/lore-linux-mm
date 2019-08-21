Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 381BAC3A59B
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:21:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F124522D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:21:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="JXBIHsFi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F124522D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6540D6B02B7; Wed, 21 Aug 2019 06:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604556B02B8; Wed, 21 Aug 2019 06:21:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CF4F6B02B9; Wed, 21 Aug 2019 06:21:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 26BF56B02B7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:21:02 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B623952CA
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:21:01 +0000 (UTC)
X-FDA: 75846041922.18.coal62_7d4020825b424
X-HE-Tag: coal62_7d4020825b424
X-Filterd-Recvd-Size: 5339
Received: from mail.skyhub.de (mail.skyhub.de [5.9.137.197])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:21:00 +0000 (UTC)
Received: from zn.tnic (p200300EC2F0A6300A5E08EBEFD6E27E2.dip0.t-ipconnect.de [IPv6:2003:ec:2f0a:6300:a5e0:8ebe:fd6e:27e2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 98A141EC0391;
	Wed, 21 Aug 2019 12:20:57 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1566382857;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=5HldHmjPtVDsjJt+73zl6zmVCWyCnVG8ascf+hIMWGg=;
	b=JXBIHsFigf7rf/+opBf5Rm5Ekjif6uD6SYKry/tXM+paMrS7u1OT6MDNykHTeDtw3w4T52
	/9jl1C9BKsaRZUQLAG7PcRSTF5dnSSfdKFJCAibbfRt+91K6pBpvmPI2CjfeCy6tEAebCH
	axlDog6P1OYaf3Z4gMdyoY7QGY034Vs=
Date: Wed, 21 Aug 2019 12:20:52 +0200
From: Borislav Petkov <bp@alien8.de>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 02/27] x86/cpufeatures: Add CET CPU feature flags for
 Control-flow Enforcement Technology (CET)
Message-ID: <20190821102052.GD6752@zn.tnic>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
 <20190813205225.12032-3-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190813205225.12032-3-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:52:00PM -0700, Yu-cheng Yu wrote:
> Add CPU feature flags for Control-flow Enforcement Technology (CET).
> 
> CPUID.(EAX=7,ECX=0):ECX[bit 7] Shadow stack
> CPUID.(EAX=7,ECX=0):EDX[bit 20] Indirect branch tracking
> 
> Reviewed-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/cpufeatures.h | 2 ++
>  arch/x86/kernel/cpu/cpuid-deps.c   | 2 ++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
> index e880f2408e29..122265ab46c1 100644
> --- a/arch/x86/include/asm/cpufeatures.h
> +++ b/arch/x86/include/asm/cpufeatures.h
> @@ -334,6 +334,7 @@
>  #define X86_FEATURE_OSPKE		(16*32+ 4) /* OS Protection Keys Enable */
>  #define X86_FEATURE_WAITPKG		(16*32+ 5) /* UMONITOR/UMWAIT/TPAUSE Instructions */
>  #define X86_FEATURE_AVX512_VBMI2	(16*32+ 6) /* Additional AVX512 Vector Bit Manipulation Instructions */
> +#define X86_FEATURE_SHSTK		(16*32+ 7) /* Shadow Stack */
>  #define X86_FEATURE_GFNI		(16*32+ 8) /* Galois Field New Instructions */
>  #define X86_FEATURE_VAES		(16*32+ 9) /* Vector AES */
>  #define X86_FEATURE_VPCLMULQDQ		(16*32+10) /* Carry-Less Multiplication Double Quadword */
> @@ -358,6 +359,7 @@
>  #define X86_FEATURE_MD_CLEAR		(18*32+10) /* VERW clears CPU buffers */
>  #define X86_FEATURE_TSX_FORCE_ABORT	(18*32+13) /* "" TSX_FORCE_ABORT */
>  #define X86_FEATURE_PCONFIG		(18*32+18) /* Intel PCONFIG */
> +#define X86_FEATURE_IBT			(18*32+20) /* Indirect Branch Tracking */
>  #define X86_FEATURE_SPEC_CTRL		(18*32+26) /* "" Speculation Control (IBRS + IBPB) */
>  #define X86_FEATURE_INTEL_STIBP		(18*32+27) /* "" Single Thread Indirect Branch Predictors */
>  #define X86_FEATURE_FLUSH_L1D		(18*32+28) /* Flush L1D cache */
> diff --git a/arch/x86/kernel/cpu/cpuid-deps.c b/arch/x86/kernel/cpu/cpuid-deps.c
> index b5353244749b..9bf35f081080 100644
> --- a/arch/x86/kernel/cpu/cpuid-deps.c
> +++ b/arch/x86/kernel/cpu/cpuid-deps.c
> @@ -68,6 +68,8 @@ static const struct cpuid_dep cpuid_deps[] = {
>  	{ X86_FEATURE_CQM_MBM_TOTAL,	X86_FEATURE_CQM_LLC   },
>  	{ X86_FEATURE_CQM_MBM_LOCAL,	X86_FEATURE_CQM_LLC   },
>  	{ X86_FEATURE_AVX512_BF16,	X86_FEATURE_AVX512VL  },
> +	{ X86_FEATURE_SHSTK,		X86_FEATURE_XSAVES    },
> +	{ X86_FEATURE_IBT,		X86_FEATURE_XSAVES    },

This hunk needs re-tabbing after:

1e0c08e3034d ("cpu/cpuid-deps: Add a tab to cpuid dependent features")

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

