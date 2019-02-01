Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3147CC282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C861A20B1F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:08:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="E/e4G1Gu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C861A20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28A238E0002; Thu, 31 Jan 2019 19:08:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 212478E0001; Thu, 31 Jan 2019 19:08:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B2FB8E0002; Thu, 31 Jan 2019 19:08:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id A81ED8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 19:08:22 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id o5so1575751wmf.9
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:08:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wcLuJ5V51PVE0zKzUOX1MtOZiwFVSnXFC3mEr9uPUuE=;
        b=pfRyzYcsqGC3mN1XelP60jnjHvW0tP4BUglwtIuYRYTHTNsfqMPAMk1b6/uti8z6fN
         YNaEIPixnc9Pzn4YqslsC0cCTMihS1sr7EMG+B3KFj/eOIolPrmyJrwMy2fxkqcrPhtE
         edCuM00H2RM2cqKLpC8238G9GFYJnMjnYJWXuz87S2FFTPA1LhknFiUupjSJXDBhQBTi
         UCKnWa2YrfvR4w1r114mhbI3f9mLBGimKMav5a3yJL1V+KkLrvoNOMkZle53GEe/oPAJ
         J6ed6OMzHiuCxvo1X06Iifzz+O4ryDvuBG7qctPF7/nMVrmUzG59p9wp/Jlr7uibQklk
         RwMw==
X-Gm-Message-State: AJcUukclHGKTzizCm6CwP9ZJC7DLnXXeDt3JznCw5XxMRVmFfhNO6odL
	TBWQ2lmUJzJfdbPA5DT4DfWnV9+dDhgm8qhIYz63WtF9HVzotAjYVlBZ1fMH/7roU7yEdDGcpUq
	sjS4kl4p2GaVrI/M5Fq7zlttCxGRToB1Y5Qrvoir2qgKsytbQ+W5mpKL4nbGUDBm2pw==
X-Received: by 2002:a5d:5208:: with SMTP id j8mr37536437wrv.188.1548979701939;
        Thu, 31 Jan 2019 16:08:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5pTNa89//sEcmOOIkGAnn3P5UO4p6+7NXGhuFTNC99hHN8eQbSPYWIjYQoWx63WeA1w8FX
X-Received: by 2002:a5d:5208:: with SMTP id j8mr37536365wrv.188.1548979700763;
        Thu, 31 Jan 2019 16:08:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548979700; cv=none;
        d=google.com; s=arc-20160816;
        b=xiddIhc0J6yReX1Qrjqzngq1IZjDU5If8qc5muWqyaCjVT6L0nMyp6bPrIRe5ByhWK
         B02FSwT6Ki3OAh3vWItFea1qv+rcttmOsmZnRWK8Mc5zG40FEHD1r+P0xTDao6NUCnzD
         76aHKsRrxGETFpIpU1yX/RwpuvmJxvEOXhohTDWsUidZgx1e13gCaFRZty8/A1pCinkf
         nmhJ6zSbCB5ru/ay4qfd9ksCuMNfXE2t58A1N0eZIu0nr2Tg5hq5/50Ljl5rMmM20OJk
         +2saOSeB2rBdM8jX0aiFu+27vuIS5F7htT8jwqmIgCdxP24/+Zl3CQXtDnwpcs5BhYYL
         ctKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=wcLuJ5V51PVE0zKzUOX1MtOZiwFVSnXFC3mEr9uPUuE=;
        b=NUy1drQ94TffjpOM+O4wsc4rwk/WEpI3nHeekKWx+dmYmsSzmdYi9WeAvw0qp/kyBF
         5NVnztcmVDQj+Q65MN4n0L4v82GJCejvPtxBu5U05P2nXYRS9CtkZ59S3/wYs9yw+416
         YL2UY5HgGt5bg/XxBnY3A+DwkAIgDMSqqnuPEok9nO4EgLqx1uhEhN3tdn0rctRPwI3D
         FRgZ+8v9g0sJP6zvH6/l4t6UnhSM02uTeMg5PbbjuBxJ7TCCCuwl7oua6CYhnXrknwzZ
         5QFnhzlTe0MP9GGWP9DDcOC0LZ/9/E5lX6gCEEceBwyX6iToG5xAclliF8OiW4kRroTk
         Y44w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="E/e4G1Gu";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id n14si4286861wro.50.2019.01.31.16.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 16:08:20 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="E/e4G1Gu";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5900604F5F4DB2DDD4A2.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5900:604f:5f4d:b2dd:d4a2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 035A41EC056D;
	Fri,  1 Feb 2019 01:08:20 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548979700;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=wcLuJ5V51PVE0zKzUOX1MtOZiwFVSnXFC3mEr9uPUuE=;
	b=E/e4G1Gu3uYJzE1+hYaUic0nJ8qQSKAbyHPaKzGpbcRJEfLIdvvwjvRuhK6A5if0R1ZV+H
	xCwh6IS5Fhejsck0mFDZ5jWttUTAqiPjY4RPhooUvPD1vkhXw7tk8wSX732icDg3J3Vpac
	aHb9W97uZCeAupSpClOU1AiNsJTnEVo=
Date: Fri, 1 Feb 2019 01:08:12 +0100
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
Message-ID: <20190201000812.GP6749@zn.tnic>
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
> Meta-question: could you please review the entire patch-set? This is
> actually v9 of this particular patch - it was part of a separate patch-set
> before. I don’t think that the patch has changed since (the real) v1.
> 
> These sporadic comments after each version really makes it hard to get this
> work completed.

Sorry but where I am the day has only 24 hours and this patchset is not
the only one in my overflowing mbox. If my sporadic comments are making
it hard to finish your work, I better not interfere then.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

