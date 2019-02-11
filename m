Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2755EC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:43:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7E8B21B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:43:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="ryEPVL3o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7E8B21B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71B4F8E014C; Mon, 11 Feb 2019 14:43:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6838D8E014A; Mon, 11 Feb 2019 14:43:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 484548E014C; Mon, 11 Feb 2019 14:43:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE5E18E014A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:43:01 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id n12so23413wmc.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:43:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+gKW9dyrdmotWHOe9duLDroxnAT+/cbjZvA/JDljj/4=;
        b=VcZ9Nyh/Gdt810LzQhmKqReXN6Wa7eCJ6uBL8WUNwOzh2s+f+RJBRY6ASBZfKJXy+f
         UQQhoCJJ3iiZbBNRIIQSvcMVG63IkwoIkghti6h7QJyQjn/2uCFXRfpbaWByagBjhGZ8
         NvJE/ACiSwKO7F6p19241R9N78CqIUoCc/QU1h1NBwEiTBBNU/fay22FeBw16nqDWMja
         NvirjsJRRDVSnxprU7rIf109o7cAFL6AJchcjfS3jXYpZ/Ee11tP7w6277gNrApHIOy2
         wDuUiFzyE1g1ts20r4JcWM312OlXGSyOJ7OX0fMAm9XQEZTiW3zASHdvQcP3RvevbzEG
         VzTQ==
X-Gm-Message-State: AHQUAubdyZx5BNgVVANN7xtbEsoxhtnLgwCngZCHg6WMZujr7VOqhdUk
	D3pSuPh8DGLHBGHEoVDFk17YJpjqT3e6aM+ZH1TMKuBgBXuNyjpL9u10tIeO9HLsgTa7HXj/gJF
	nESD6PVdhLVaoQh4hH1JSZFxvrr9pkEhVl6ObaKJNZAAFiyF1jiQgYulzNQo87FnE4g==
X-Received: by 2002:a1c:6a16:: with SMTP id f22mr835786wmc.25.1549914181399;
        Mon, 11 Feb 2019 11:43:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZhbxchgyhjhxhu8NCxVm8rwxUXzPk6tN9oYvHpTccW2Gv5ZWHrUNB6BfaA6ewV+kyDY3x
X-Received: by 2002:a1c:6a16:: with SMTP id f22mr835747wmc.25.1549914180642;
        Mon, 11 Feb 2019 11:43:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549914180; cv=none;
        d=google.com; s=arc-20160816;
        b=TGA5ss6xzwQ7E036V1CbBXB15bPSFt0wTJE4zzr3ZvCXoN/TlOqrb1e3AWQDbjkvE8
         fL59QuWOeB4wpbIS/x4O40zXsRX8aivplYDJsGMbbj6Xp/PXCc35fieFGLXl1i2Q9WSv
         Xts8BI9xum3kZvGRbuxYv9P5I2YIchtjIsPVEZFupDW8KGfusSAFVGQDmxVhYMBsycj1
         Z6RxS7KW2Rc1r7rDL2b619XDZzMoLH7Rsz1dZzuOshelCcs9Ecax3n5UqtUjoxCJEwt/
         OB0Z0GTQoaNwjXbkh1Mg70nTh1vFFZV/w7K+otnsHzGocNdyVz/vt3vv6G04+br7/aoA
         r6EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+gKW9dyrdmotWHOe9duLDroxnAT+/cbjZvA/JDljj/4=;
        b=vAh56PUxVKu3qLGC5MqAJsst7feGcaM1/b3o+OQtEzThpa89NDdqnC3dklZNb7UXQk
         EFA7rsMZrGQVHtJ7GFc3Vm5fyE8NA2Wx4N25aWvSVVGZc6DIkzVF3VYR44ZCAU6a9SeE
         bs3ztQ7NZMmqc/95/MtWiCF1bvaskpPRztMMFOZntIjUtwloRWzGvkBHzzZUDi9jzosw
         cMS9iszN0wLiQcO+ZJiKgLovyAArxL+neg0EBHf2pQh0dgRtSQIcweeeK8Qj8NyyOIDs
         y4WerCTc1UQb+87eXIiv5AiGhO3H8n5nDjkz9+ZNU18rNWG6fYnjrdnpv7B5kMQUo2Zz
         ULXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ryEPVL3o;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id v13si8475281wrs.30.2019.02.11.11.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:43:00 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ryEPVL3o;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A100D435EAB708BAD763.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:d435:eab7:8ba:d763])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id C15751EC01AF;
	Mon, 11 Feb 2019 20:42:59 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549914180;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=+gKW9dyrdmotWHOe9duLDroxnAT+/cbjZvA/JDljj/4=;
	b=ryEPVL3oTtALDvJ8cDIc+0KJtdcitxb40vihVDnWdIdXjZ6isjCTUoM6PCuhi2jnhtfGFL
	E0NI+P5yhxp6BB1Ta3o0oMw1Ay4p2Vo7bvPytCD8SS5ycVqqTpNX8RqXhUdQXrf0XhWM8M
	Btad+B7ZL7KPEAB6R+LP5YU1nECVJ6E=
Date: Mon, 11 Feb 2019 20:42:51 +0100
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
Message-ID: <20190211194251.GS19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:27:03AM -0800, Nadav Amit wrote:
> Is there any comment over static_cpu_has()? ;-)

Almost:

/*
 * Static testing of CPU features.  Used the same as boot_cpu_has().
 * These will statically patch the target code for additional
 * performance.
 */
static __always_inline __pure bool _static_cpu_has(u16 bit)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

