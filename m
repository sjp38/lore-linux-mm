Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A55C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:02:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E3452064A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:02:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="MMTf+qM5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E3452064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7AAF8E0004; Thu,  7 Mar 2019 12:02:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D03C78E0002; Thu,  7 Mar 2019 12:02:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA45E8E0004; Thu,  7 Mar 2019 12:02:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65FB38E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 12:02:55 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t133so3492947wmg.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 09:02:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y3qq1FJAtgMcBrhxJOuu6fPyW4x/qy6rfTwk7P7bdN4=;
        b=anm5ob8WlCsTxdAgkmbR4oSSOqCN1UwoI7U7L25NdC2wJfbx0THqfc5G+rf3Wfvy+G
         fsqCKwMS9Ok9dkKE+6qE+mmBxRoQJU+tLqsSnUGGWNcZUbpeYeu7h+P87vY4FxOMgpLY
         VL905netXVeAY1es76j6MDlNgVVhAZzPnhbeDKJg5TVOjioKO/6SsfTFPLcDCibsd2K2
         NWzX3IRWcNH2mc4IB1YYNmUTse5V2eDsr/FtoxVCxNkk3FNuKc89o+eEkhHPVJuYv2vx
         xf7TkpjVCOYjTkrM4xuJRJfwNPIqWYz9nIGq9tU3k50M501pxGzkLEMPq/es5SOliLtn
         A12A==
X-Gm-Message-State: APjAAAVjJdGfqo5CLN0lDMYXkMPb5QIzR7xgnjGNu33qpyXEmJhuk+nL
	snhpZT6OkuSpxSqpos/WenoxkR5103diN8Ph+BSjHeyNdAlHm2eRfAnyVYSVj5ALwoZsoRKhMkT
	HMYT+JIrFTCOWigRHBQb130zqbR1V2JI9iEsrtY9X2QPBeqzl3nCXiYKiRv0AUChh7w==
X-Received: by 2002:a1c:2082:: with SMTP id g124mr6084744wmg.59.1551978174815;
        Thu, 07 Mar 2019 09:02:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqzMCLU0kyH/5/3mFLO52qHiNvHpP6GzHsfp6AVzwZb3aNrBLQ+ZgQXPmLmaNqq3OD8tUQtf
X-Received: by 2002:a1c:2082:: with SMTP id g124mr6084673wmg.59.1551978173274;
        Thu, 07 Mar 2019 09:02:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551978173; cv=none;
        d=google.com; s=arc-20160816;
        b=kVHNHpzet5FVhFY+RYps+lKIr5Qx0PHTpJnza1vPc59xyFtT7vwWUvms6lVUvm2rpB
         OF3VLL6qdpxyiCEw6SU1if8CBbG+THBdPamlCBJVy/SvsdhS/u8kxE8fRGQWhzfZwWgD
         OhyUkE21UNCua+pSRX9Ycq3PeHBTjFiayeCXhtdrIjleJphzY8toiW5XKPX/QXQuebzp
         HYw5Qn0iVsuC2H5vg9DboPwfthFfLJjvjtOZEufQv0zZ9BtkN+0kYr4LpZRd9Nb5q3op
         N6AvB5aZuLUTScumCga1+TbETbcHQAszQp/EKEBd9xV3oFXDg5GV37LY/9fXi+DyyfL5
         Xx1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y3qq1FJAtgMcBrhxJOuu6fPyW4x/qy6rfTwk7P7bdN4=;
        b=LqknQ9LVdkuIdVZglhkpf2TF+LRVaefwdeFqUc3BDE3KQrS4hPq3e/Z8XOFicUFOHU
         ktAuzP0BGyDy8KjFA4QktM0pPOo+i27e+36Jk5teHGRwGJs/iMdN4dAOmX6IukYrLr5q
         h0vJc5/uqiZhyp7uAz53xoBmk2UbIR70Quv/UYahif2skM1hxBSAL0zUp2n/dy56oWPe
         rSCxGokU6fNJxkjxRAgz+NCIOwGJ4oeGVFcfLzRErFPQE11zzxg/8D/oIYNf2oZ4QKEx
         4eOmKtrHvmOLCDEvJfAe3uoMJ47nTE29JODNq3zDd913titQ739Kvk/2oI0dXM9d2fF2
         7gFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=MMTf+qM5;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id q187si3193821wme.95.2019.03.07.09.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 09:02:53 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=MMTf+qM5;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (unknown [IPv6:2003:ec:2f08:1c00:329c:23ff:fea6:a903])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 71BE81EC066F;
	Thu,  7 Mar 2019 18:02:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1551978171;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=y3qq1FJAtgMcBrhxJOuu6fPyW4x/qy6rfTwk7P7bdN4=;
	b=MMTf+qM5o5XuoSWwaEXahf1r1N0Uzibm438tZBQJCyJa28wh0t3NHqV9+LCJc/KAUVt0F4
	/cYa61X4/5ES4JmSh89MXAEWV0xafzdCuIDLPjbWxu4Gu8NVU7b7/xRFzc2AGidX/jTp7x
	sA46QeeJG2aL3u03dxDA5CCVDdKx6F0=
Date: Thu, 7 Mar 2019 18:02:54 +0100
From: Borislav Petkov <bp@alien8.de>
To: hpa@zytor.com
Cc: Nadav Amit <nadav.amit@gmail.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
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
	Masami Hiramatsu <mhiramat@kernel.org>, Michael Matz <matz@suse.de>
Subject: Re: [PATCH] x86/cpufeature: Remove __pure attribute to
 _static_cpu_has()
Message-ID: <20190307170254.GF26566@zn.tnic>
References: <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
 <A55214F3-CDC0-44C4-AFB6-7E8E23CC6F85@gmail.com>
 <20190307151036.GD26566@zn.tnic>
 <D683E00D-845E-4970-80DE-AD1DED3AE609@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <D683E00D-845E-4970-80DE-AD1DED3AE609@zytor.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Lemme preface this by saying that I've talked to gcc guys before doing
this.

On Thu, Mar 07, 2019 at 08:43:50AM -0800, hpa@zytor.com wrote:
> Uhm... (a) it is correct, even if the compiler doesn't use it now, it
> allows the compiler to CSE it in the future;

Well, the compiler won't CSE asm blocks due to the difference in the
labels, for example, so the heuristic won't detect them as equivalent
blocks.

Also, compiler guys said that they might consider inlining pure
functions later, in the IPA stage but that's future stuff.

This is how I understood it, at least.

> (b) it is documentation;

That could be a comment instead. Otherwise we will wonder again why this
is marked pure.

> (c) there is an actual bug here: the "volatile" implies a side effect,
> which in reality is not present, inhibiting CSE.
>
> So the correct fix is to remove "volatile", not remove "__pure".

There's not really a volatile there:

/*
 * GCC 'asm goto' miscompiles certain code sequences:
 *
 *   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58670
 *
 * Work it around via a compiler barrier quirk suggested by Jakub Jelinek.
 *
 * (asm goto is automatically volatile - the naming reflects this.)
 */
#define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

