Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42384C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:01:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00A1920863
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:01:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="AF/C1MIM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00A1920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89D718E0135; Mon, 11 Feb 2019 14:01:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 827568E0138; Mon, 11 Feb 2019 14:01:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F0528E0135; Mon, 11 Feb 2019 14:01:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 134EA8E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:01:17 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f5so440136wrt.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:01:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qWpDfY9hdZigS4Dtjg1dc7Cbm4tCe4w1qekSQJB7WTQ=;
        b=SFyxuuHQvuHNx6x++M1ON0DKiv4T/bOX4rpmXwQlYFyHR4FrXIErYhKBDt5hJ2K0Ye
         aTPXXNH23p9i250+22ZESp5MmoT6+rvAx5i5PG7vs9iGgAgcwgwfwuNFbTktV1uqqaM4
         Umh06lQBeSKUwonqwYgehRy8gL790uK77UhQfxHlLxbW9tq6lXDCU0ZEE6l6lKgLo8Bp
         c2ZtatJdw92t6LZWeJlNVpbnrG0374xzbpVVHn9YC3DHAWEqOWKMP2wqURhmS8wKg540
         4mLUUyUEjtwrtlxsk5AqDe2cAhmbSqbKtqCR6YMvJaSkDfgl0zjq1RB9w80AsQ+l5E0a
         rc2g==
X-Gm-Message-State: AHQUAuZkDq520INguWnpJuirFDKpLFSIz8JT5qFFu48yNJQkEQfjw1Mn
	cKpTTkBHmQfPSoKGhkCrQtRS+bqA0gaZPrntXPcl1UZgVcKBZNIX709NzuAhRu1N/pAS20lxs6c
	rpxz7ZF0MpRUm3Po4TSvuB4xX7zKZZ/o5PX4uxYkPQIz45o+P+np61t3tVeMTc4VngA==
X-Received: by 2002:a05:6000:10cf:: with SMTP id b15mr28345100wrx.301.1549911676638;
        Mon, 11 Feb 2019 11:01:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDJYTri+4kAMwwLaGJav88SYOLM11fvzmWpv+hIwJK1Nl6W5odcaJRjC2QLbt4YSaxZUzT
X-Received: by 2002:a05:6000:10cf:: with SMTP id b15mr28345042wrx.301.1549911675596;
        Mon, 11 Feb 2019 11:01:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911675; cv=none;
        d=google.com; s=arc-20160816;
        b=tCQ2FT2pdPAh7f3M0qf5SwtsyhZJziLIdYDI0l1b5slo0JPZkxPtqceqcpP/nRM4J/
         iGeUSCiU6c6Ah6KWnXn9uwAueQ7d/1jMXg9STg3vSOMvqiXlKt++nixsffpAqRoFE1VL
         2giH/lrZCyAfcp839GByHAQpu3hSSDSTsgqjVVGXzNOCXpLH8/SgGJo/Ihx8xK564MTy
         GQp9AEOMA9eRlWmTnYtcAyXFS4MqgZI3K4RhVJUi5VPSndx5RniEfDD59qANLR0ld4MV
         GlRnPLZ5WnMvZfWwx/dAqlGExWDRRZMuH8cWVMXt//rJ6RDz5YceaM9hrDq8cTnIZh0m
         7kBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qWpDfY9hdZigS4Dtjg1dc7Cbm4tCe4w1qekSQJB7WTQ=;
        b=HoS7g+W+rT0d9aXQg6LkyVZ6jc3u/j/sW/diN+LDAxEixnbSfaAcFlj2NTTOvNdjIn
         2MX4qz2Ss4iQOER2n5fQ0hP/HtSlxuDGrm1r/gBHTqFrMysWjeGI+bK+NDyxq3Lbj7Mm
         oNRIIOvcmTMD+gzpYnrR3/kwP+66rZt/y1gFmLPMAQq501Gi+kQ+e8TEp57l+DAs1JNY
         IlKWBAlcAfZxgZ7te/d4liFrkoWTCiogeIGQIJ6iQdKQEB+NonXw4agAI8h8mxkUzfbo
         +6vl4XLXdCE64+38q7crMYhaNR5hufGpDN0qiodk36cX/moXN+pYdbY3n8zEWKvk/RF/
         5NWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="AF/C1MIM";
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id a16si105272wmd.137.2019.02.11.11.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:01:15 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="AF/C1MIM";
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 99AB21EC01AF;
	Mon, 11 Feb 2019 20:01:14 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549911674;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=qWpDfY9hdZigS4Dtjg1dc7Cbm4tCe4w1qekSQJB7WTQ=;
	b=AF/C1MIM5X+09YOUt8D3qKn3HVAOfhn+qR7SVoJP7VlW/9RiKKb8XDrl7Zd3X4x34F3OWA
	itb3pR9IU1oePmeRJRAkXZ9WkBzL2B8pr0SohcMKAN8/JjHenMUuFOgfVr3peRm/Rlddxu
	SFxivBRbCkhNC48c5HPHOLAKykBGhLw=
Date: Mon, 11 Feb 2019 20:01:08 +0100
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
Message-ID: <20190211190108.GP19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:45:26AM -0800, Nadav Amit wrote:
> Are you sure about that? This path is still used when modules are loaded.

Yes, I'm sure. Loading a module does a gazillion things so saving a
couple of insns - yes, boot_cpu_has() is usually a RIP-relative MOV and a
TEST - doesn't show even as a blip on any radar.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

