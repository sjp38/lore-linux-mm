Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD154C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:37:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A41221B18
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:37:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="r2L6NSU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A41221B18
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E335B8E012B; Mon, 11 Feb 2019 13:37:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE0A38E0126; Mon, 11 Feb 2019 13:37:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA98C8E012B; Mon, 11 Feb 2019 13:37:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 757348E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:37:53 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w4so1946190wrt.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:37:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MfO9iraTHgQ5nRXoFHrsSYSHTedG1aQEDckVc6y+oB0=;
        b=g4jf6obAHuaWp+Roe5h7ZJgsan/I9F9rL9jILoKhyqUVp0HU5ww5+AgLjVkCbunXtW
         yBnF3ZZoSAFmGAqFntZTBdQ0aLGZOiGK+/6Ss4DPowLD3wIkUEqh6VN6Dusv326U8RNI
         VKPBzscre6Ua6C8WaCXuXV7hxx3UgqJUApfNuyBtqDxOevGfErlxOhPjerQ7lJTTDThA
         oEimU7lMDb7c2HVVtAbhli2DwwItk32Ay8Aw4Nwx9fBDjAzI/bMRUZvGX+A+sV/ZStiL
         OJ3xrqfDDvlDWS4dBUDmCQcS1xnpMYhubb3A0CRbkE6cQS5qmhj0HfUV7v/s8Tr5cgnx
         Bmgw==
X-Gm-Message-State: AHQUAuZ8RwHDj1t/HM8odoZASaeaxxNv2Va8LT/vmi9T0miYdtS2orAh
	2/j5pPAqSArtfmgUEBSmIY9MvgC+0Wt+imM0kG5PQpGWDHoUkwmRMRJgni5hyH4AC1Z8wVSpDYb
	83ri4uYsqEP2EW0fdc9YOVsMu3OSTCzkAr6SdJYKXIBym42vbfRqEKlhYQ5vxTjMpsg==
X-Received: by 2002:a1c:4d06:: with SMTP id o6mr714568wmh.6.1549910272907;
        Mon, 11 Feb 2019 10:37:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaO7Dihl3rEp4YAkftMJc4pS0tbzH2uSNnt92uC4o0Mkme8zS7ds7okmLu4ju2Uryj0/QLV
X-Received: by 2002:a1c:4d06:: with SMTP id o6mr714523wmh.6.1549910272107;
        Mon, 11 Feb 2019 10:37:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549910272; cv=none;
        d=google.com; s=arc-20160816;
        b=a1aidg8n82B2sScRuM3gKaxFMzP0tdAUum+/Qpu3Ezd0k6uQt9oyQFjSykHFYnV7Km
         f5UmhHTQAPPHmxVlu/sZs8SRSRO29zcaRQ8+W1lYgYcFd1rjIIsM/Ghk97EsUamYmWfb
         Dv3IljNaJ+XiYP/CpbmdB3pI8ztItPOKCYnjRKE6zw8qKxtKofrQyuuxk84pv113MwjI
         aKiBkvEOl/qpxAnBPngXReYh4ChtulrMVppRuT3eWFrvf1MEYddw9o44q4kxGYwabVF7
         HFb974wioHq+PdKSKg2ABgYlVlQ/x7IkcRZ7lIdiX0msh4/MYjTJF0vjAYCvor5xfZw5
         Sf4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MfO9iraTHgQ5nRXoFHrsSYSHTedG1aQEDckVc6y+oB0=;
        b=s39Lp7NfGZmUYwQFoPSlJ3lqq+VwcEHq0WvE5ilcq0wJ+zC+GJzkaAdJlVpAjeNGhF
         e7wrkmA3Iz1u/paGf55zyRVaPtsg1fyhXVF6waI4662aSGejyqgUGXo3DffMhwMfpbHZ
         1jBpR65xMN9meiCTFoCEZpOyRBs6XCJt34Y7mZzUr87TmgFIlnHWfYuYXcdAJ/tg/kga
         b8E8d7diaM5ulSKahinCzsaeo5w+nr6LtB2xppHtxoYsk7x9MnNGF3Dz7I5W+HCVzyDD
         vahY3OXz8F/ZTc6+JYI/UrQ4DKzKs8d4Kw88GxoLaHnkMPXqRD/u19BwOap5PNRt6fYm
         M9ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=r2L6NSU+;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id a145si52132wmd.142.2019.02.11.10.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:37:52 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=r2L6NSU+;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 21C861EC01B6;
	Mon, 11 Feb 2019 19:37:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549910271;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=MfO9iraTHgQ5nRXoFHrsSYSHTedG1aQEDckVc6y+oB0=;
	b=r2L6NSU+gQRc9eP6vhleihhYe7ChDGrNf8u5AA7D2wpuQbAZ9Bm0Fz5kkiiOWDABu5rgBs
	As+h0/3tG84bT+jrIjuMOOYQO8XGlUjnVh44QvtfpZ1OITxv8f66lXFCe/4GWyL1/RzF2I
	qLvosFPyppk1t5t1d/CoLxnOtlB6MAQ=
Date: Mon, 11 Feb 2019 19:37:50 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 11/20] x86/jump-label: remove support for custom poker
Message-ID: <20190211183749.GO19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-12-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-12-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:13PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> There are only two types of poking: early and breakpoint based. The use
> of a function pointer to perform poking complicates the code and is
> probably inefficient due to the use of indirect branches.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/jump_label.c | 24 ++++++++----------------
>  1 file changed, 8 insertions(+), 16 deletions(-)

...

> @@ -80,16 +71,17 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
>  		bug_at((void *)jump_entry_code(entry), line);
>  
>  	/*
> -	 * Make text_poke_bp() a default fallback poker.
> +	 * As long as we're UP and not yet marked RO, we can use
> +	 * text_poke_early; SYSTEM_BOOTING guarantees both, as we switch to
> +	 * SYSTEM_SCHEDULING before going either.

s/going/doing/ ?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

