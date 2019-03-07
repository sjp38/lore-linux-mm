Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBCDDC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7DFD20851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:25:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="aBvUi/RZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7DFD20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DEF78E0003; Thu,  7 Mar 2019 15:25:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38D918E0002; Thu,  7 Mar 2019 15:25:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 257448E0003; Thu,  7 Mar 2019 15:25:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4D088E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 15:25:24 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id m2so9044524wrs.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 12:25:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j/Do6FnvCh9OWtdg4UwDiyiIzDztecvEbbA6xQuvclY=;
        b=oUmZbXFWidEwnF4ffADFux42Fnwq4ByI5J/o64n0vimcfLASzuUVa3Se2RewT9I3rH
         +0pJ671MkpDax9vTLFHkMRWiuemeSSNWxKh9tueIpJ+EF7mu4mpGoHzUjHyVAgsOL6ix
         AwnkW8eCSRSN5Gedds/Bzln42C1zAMbsnJiCjRYfqwkLx3DqMndYTSWqFTz1fIHnrnSr
         qg1CYqOVddCA3IUEUEsr5fUWu8eH/41KpWHAHxVr75t3HXsEZzizzQ10jYOQ8Ij1Z0c3
         +Tl0FmqAqW7MyhzS+zsTM6OKxQiMSS9PgAPA8Uo+yNlMiPwsEIF+m64VyS3NLonmGF9c
         BEGg==
X-Gm-Message-State: APjAAAW8HRFfAvvjDI/KUxqK0l17qaaRAt7aDgBbhowOftyfn0qKZem1
	MToYZnTxg3FYb/p9GtjgHzZOOL+CLi3Lwm5D/BKid/n+uUw3GTSpmcwKb5KRtZsMqu1/JOe7WIB
	V13+EVHQbF9RFtEslqclxYHOysElaK5Ko3tvodQkXot70eSAWkCnAAh3FCkcK+/VYlg==
X-Received: by 2002:a1c:449:: with SMTP id 70mr7012856wme.118.1551990324205;
        Thu, 07 Mar 2019 12:25:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqyX5Y9vZSfyuMaA27IJwr2WCUfPn4E77IOMnZsR39PiUX+elt5Wa86Bnz2i5JZZTM/1J107
X-Received: by 2002:a1c:449:: with SMTP id 70mr7012826wme.118.1551990323313;
        Thu, 07 Mar 2019 12:25:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551990323; cv=none;
        d=google.com; s=arc-20160816;
        b=yJQwflCIz2/vIQyt2uLCg4NxOe+69OmHGH03E+8mf4EoQot8uQZg0BUEoIe8v/jeP0
         B1/Fo0wrd9MO2rdpJshl5+QL+wBdyBbhssUKxw9ov1iGIl1nGIH1d0IpZ9I9cPKYctai
         B8slh5biaP+dY8nFoju3WqEyHzTwYMNXfNMzLcTttuQ4ROXyfs4JiT8qLrB/TNwqISy0
         3IPXwFBb985+XDLDaNw1gkwJt9boP5ZNU/amJvSI3nPut3udvOjtR4X7Im+gtHbbtNU5
         Cni1Svaq0BWDXf/7z9Ur8jLNk7q2oAJQDKcOPqg5EC7nHtZ3X/xWZyLmPn6Hear3nlJ3
         1HMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j/Do6FnvCh9OWtdg4UwDiyiIzDztecvEbbA6xQuvclY=;
        b=mM6XeELgnk/Cbm5usgEU7dPIpNTegk5fFD5t9iVwXxE91vj68ZPlYRyxnBwo2dI+G5
         Ltq6uOGVMXhL2U+iL/gw+kvrRPvQai9gVJWJ97DnozX0HD+YaIXc6t05dPlTanVpqaKE
         qh2fH8zNRO3mbqchNXNsEPyCuB371GOapnsFXA31WGkbbH+PU8Y5h8avuWHnZAtMu8yS
         YBnmO94JcCRRuPGFQvVos5OqYe6hkgH+a6exWh5+lNmFY234iQWBKCZx2BcgY9xTdhEX
         +g0lwww3F+l7IaBsKQ3bOSbSizDw4XUxTSgFdlmVV1ZfyjoC65p2p7EG+rZvnzJhAohu
         0ELw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="aBvUi/RZ";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id f75si3723186wmf.166.2019.03.07.12.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 12:25:23 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="aBvUi/RZ";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (unknown [IPv6:2003:ec:2f08:1c00:329c:23ff:fea6:a903])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 763061EC0310;
	Thu,  7 Mar 2019 21:25:22 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1551990322;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=j/Do6FnvCh9OWtdg4UwDiyiIzDztecvEbbA6xQuvclY=;
	b=aBvUi/RZBy5hLhXC9ghHsHwWVyhfiXmOlm0vRVntsr42HLaa+xL0sWYOf+zUocpD+0kkli
	o4ldSkPaUMEFRHUBFH//43BRVvBzk5aPv24Sjn3ok2I4wA0MjBhCvtU6hiKRtfZSLizm9u
	3eXMMHV8IynSPH/ZJp2eGLcKZIRwZrM=
Date: Thu, 7 Mar 2019 21:25:21 +0100
From: Borislav Petkov <bp@alien8.de>
To: Andy Lutomirski <luto@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Nadav Amit <nadav.amit@gmail.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
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
Message-ID: <20190307202521.GI26566@zn.tnic>
References: <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
 <20190307072947.GA26566@zn.tnic>
 <EF5F87D9-EA7B-4F92-81C4-329A89EEADFA@zytor.com>
 <20190307170629.GG26566@zn.tnic>
 <CALCETrUY6L_Fwd9CZzo2eZL8HT2sBSHFiD-Bp-HCPPFBxkzcdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrUY6L_Fwd9CZzo2eZL8HT2sBSHFiD-Bp-HCPPFBxkzcdA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 12:02:13PM -0800, Andy Lutomirski wrote:
> Should we maybe rename these functions?  static_cpu_has() is at least
> reasonably obvious.  But cpu_feature_enabled() is different for
> reasons I've never understood, and boot_cpu_has() is IMO terribly
> named.  It's not about the boot cpu -- it's about doing the same thing
> but with less bloat and less performance.

Well, it does test bits in boot_cpu_data. I don't care about "boot" in
the name though so feel free to suggest something better.

> (And can we maybe collapse cpu_feature_enabled() and static_cpu_has()
> into the same function?)

I'm not sure it would be always ok to involve the DISABLED_MASK*
buildtime stuff in the checks. It probably is but it would need careful
auditing to be sure, first.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

