Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52090C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0339720675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:10:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="VxevkReC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0339720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 914948E0004; Thu,  7 Mar 2019 10:10:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6508E0002; Thu,  7 Mar 2019 10:10:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78DBB8E0004; Thu,  7 Mar 2019 10:10:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20FDB8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:10:41 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id m2so8687206wrs.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:10:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kdSZyLABXvjmDygL4RnuOnEqI4iIDZt3NsvoEDPNehs=;
        b=dr/brXB3n37+D2Ubbw7GKCl7BD6g+gQNe/4BLvh2sp6oH0LrYZRx4A/Wo5YWxVBOcj
         cnaiZoCGtAFXvcqYk+vkHY2HQXxqnFwwsSkxvuC1YW+REljCF/FybQEZ6E+xgbeeZB84
         mriw+7gFoNIKQZ4JS/QkKlj4MxQgQqkRuYx2qOaKmOEGBGuou9Kr6VoJe3RLXRe1HRi0
         jTvyhxvCleiCwig4FarsA2cOpHPozD3S/y0XX46mbsKoiCEbPheCXOzo6NoIcb+u6zJD
         vzhVJ1p1+Sp2ny7IfPMCs/L0n4brMihW9myNA9X79REkHbdQbZh7vLMhJ0IpXX4YvRH9
         vjEA==
X-Gm-Message-State: APjAAAXjRBPu+pwuhEYPCfDgaTrc453DW1BeqFQNBrAI4F8brS0mO1qC
	bDFzNiT4m7DEAUipzEDlydvE2VlAQlynns1EdBjVssdgCuf3EOVkwXQOM2y3hWWQ5nd0PBsuSuQ
	reaMBDjgLj7ZVT/jojyNxfT8jvjVBLzoO8ydPDcY93hokxrqmR4NTUCyyYFTVs7yZyQ==
X-Received: by 2002:a5d:674e:: with SMTP id l14mr7247397wrw.163.1551971440379;
        Thu, 07 Mar 2019 07:10:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqx0vzGCdZlC830te5tmSbJAFubW2vzYyOLKCSr2m3+H85A6vZbiN5u6FOY2DdLsaYwNCxln
X-Received: by 2002:a5d:674e:: with SMTP id l14mr7247308wrw.163.1551971439072;
        Thu, 07 Mar 2019 07:10:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551971439; cv=none;
        d=google.com; s=arc-20160816;
        b=mjUkNbKq3LEUKqWLFR9XtzibZCMRMNS34P68GGg5gNOEpGX7oDB8muqUUoW6ZnaV2N
         L+s9IMJKlZYdhtavpFZ8ZClhVIeaQd8RSMtx6dX0za7Sqd6aqo6zBoonvGQSlFMGFGKn
         YunZwKdRViVftpnBcVaH+GcoA5CwsOAQafulT00yTjWBUxVYGObcmIad5YIbSJNnJMtM
         8/0dW8ld2co6ulSTXv8ifFsiAT8DV2+1Bemzmlq/YtfqZJ4zzskdV0em7r7Yd6Rzm2N4
         ngkU1pQahw0VbXwU1Sk8FUVhyQQZBt0zqB+MnVwgOJNKmEMJSNluhZ1CQJRT5WOsgVEb
         qUAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=kdSZyLABXvjmDygL4RnuOnEqI4iIDZt3NsvoEDPNehs=;
        b=NE+4yqpIx+ghePQIGfxLLyXG7R++91hwNMIA18YEFS5z+fnqYQIxXf4IBMIqjLrQ+s
         bmNuiWnKXYSrpkbM/QzSbKygVArnE7wIv7hYkpcrOpwMj+vJ4D5WAoH+a96SSTiaue56
         iAPxW8XmcYf1K2+uB/dYOMZprkdLmoTsOHb1nCJllIEvp9c55xuOJws/jv2iUtahgFts
         miRBs3cnY1rBXSVfUA/ztmrlLMqn4EvZpZgNmq0VeByyjncwrclaUypcMpgjGGx1yFNZ
         P8ng7gu5vIkaOvZiW3fHG1OZtviVdndTaplYE6WbknOgo9F9ZDC9TvatBmab8uklee/q
         75Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=VxevkReC;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id l25si2742282wmh.140.2019.03.07.07.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:10:39 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=VxevkReC;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (unknown [IPv6:2003:ec:2f08:1c00:329c:23ff:fea6:a903])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 3062E1EC064E;
	Thu,  7 Mar 2019 16:10:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1551971438;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kdSZyLABXvjmDygL4RnuOnEqI4iIDZt3NsvoEDPNehs=;
	b=VxevkReCqFwOtl9CNQIPP9gjHkfkPvNXF6zSFMZRSq4+VQyXRKowRR/y94+03BL2OMZmB0
	JQQG//BggqJOuKLDfIrnnXfUrkBg3eVnqigcbNhNnCeNbO6HYPrevRnsTSodztTdEEAayD
	MGAXCsKnyh7965zUMAu/+Ts/W3nsU8E=
Date: Thu, 7 Mar 2019 16:10:36 +0100
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
Subject: [PATCH] x86/cpufeature: Remove __pure attribute to _static_cpu_has()
Message-ID: <20190307151036.GD26566@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
 <A55214F3-CDC0-44C4-AFB6-7E8E23CC6F85@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A55214F3-CDC0-44C4-AFB6-7E8E23CC6F85@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:32:41PM -0800, Nadav Amit wrote:
> BTW: the “__pure” attribute is useless when “__always_inline” is used.
> Unless it is intended to be some sort of comment, of course.

---
From: Borislav Petkov <bp@suse.de>
Date: Thu, 7 Mar 2019 15:54:51 +0100

__pure is used to make gcc do Common Subexpression Elimination (CSE)
and thus save subsequent invocations of a function which does a complex
computation (without side effects). As a simple example:

  bool a = _static_cpu_has(x);
  bool b = _static_cpu_has(x);

gets turned into

  bool a = _static_cpu_has(x);
  bool b = a;

However, gcc doesn't do CSE with asm()s when those get inlined - like it
is done with _static_cpu_has() - because, for example, the t_yes/t_no
labels are different for each inlined function body and thus cannot be
detected as equivalent anymore for the CSE heuristic to hit.

However, this all is beside the point because best it should be avoided
to have more than one call to _static_cpu_has(X) in the same function
due to the fact that each such call is an alternatives patch site and it
is simply pointless.

Therefore, drop the __pure attribute as it is not doing anything.

Reported-by: Nadav Amit <nadav.amit@gmail.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org
---
 arch/x86/include/asm/cpufeature.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index e25d11ad7a88..6d6d5cc4302b 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -162,7 +162,7 @@ extern void clear_cpu_cap(struct cpuinfo_x86 *c, unsigned int bit);
  * majority of cases and you should stick to using it as it is generally
  * only two instructions: a RIP-relative MOV and a TEST.
  */
-static __always_inline __pure bool _static_cpu_has(u16 bit)
+static __always_inline bool _static_cpu_has(u16 bit)
 {
 	asm_volatile_goto("1: jmp 6f\n"
 		 "2:\n"
-- 
2.21.0

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

