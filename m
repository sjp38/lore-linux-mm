Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA453C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:22:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9960B2186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:22:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9960B2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43DB58E00CA; Wed,  6 Feb 2019 11:22:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EC328E00B1; Wed,  6 Feb 2019 11:22:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 303FC8E00CA; Wed,  6 Feb 2019 11:22:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E46278E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:22:18 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so5571784pfi.9
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:22:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xs3UjPefeREr0pIXPymWQO9VhhZxWz0HOr7sMdXb3aY=;
        b=ZLKAXbPKZMDcWykY7dM4NwnG5h59x5Twr0qFNV7iz1/DzH31TY/eDgIDU2l/LZ5Ca5
         LduSq4ktG1x4RlEGoWH20BTEKB6BHXo3BNLJvcF5FeYvOd/FII6OYItcC+mWw2+KAfPR
         7yl1RJDcXu1vWnpCn53jZ4KWwwO8/yr5gQoLh32P6G1dzkfqtX+C8SswKlZqQEAvUzIV
         HxQC+Wr8GaR+m8/ADV4G7mz5UR3Y15p0yN/yntQmKmlSSeMBCgZcNflLtl6BpilDaZyC
         VR9n5NN1e96Rf4mKffLz6dW1Yagt2TaS5T+jG131IXtDy2/Jo2MbVZtapeggEGk54hvG
         ZPRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: AHQUAua4aEJG8Ve1n8IvdYPr4U1SN086E+Mw9Q1Vr8cKxdYb2BfeP7R1
	qX/c53oH7xsrKYHPZZmdbAYGsSiLb+jNQQoRcmpdW9hEOBHZfXuB/32cay/Kg/alLUvNlSAcpPX
	4kjfllIcy81lQHjfwYb6IFZQJFPQfqUEr2eTJdwohqVmQEyIimm+ntKMi9TnmVLI=
X-Received: by 2002:a65:6491:: with SMTP id e17mr10196063pgv.418.1549470138550;
        Wed, 06 Feb 2019 08:22:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZSJQu9NqB2WrQC5V1UIJTY2L3l88iZ2aYDnkfeocrAQxAMFGZE9NTby9XtzOp+sAknUp1u
X-Received: by 2002:a65:6491:: with SMTP id e17mr10195974pgv.418.1549470137206;
        Wed, 06 Feb 2019 08:22:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549470137; cv=none;
        d=google.com; s=arc-20160816;
        b=Ykp52LkwcgFUS1txnhxhFhZLSDGSl9sfsF/P6/F+XCvugNSvJTQ7R2Z7HFTFB8Kg6L
         KqvNtJXNQIsudsHaXcDOu5GfM9NFoI9c6lLLkLcFOitetm39WdirFdrH7RqOKwSQhrvz
         HH52XB2HH9sUxCu4XZrGdBpIkv1WKdZF1ujh15nvAy4s3NGU7K6ir4C4n2Djd8YbqSix
         dZZA+APmcXFKZuWEtcowV0Ae7GLF+4aKyv4i63McNkhnggMHt6h0jv8ChEvSLVhnonJZ
         y2I+kbQGoQMPseX+FCCNZvHh1hgkjD0lS5wd8s3CqV5m8DVsqV04Nle9l4aALL8yE6mh
         sVVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=xs3UjPefeREr0pIXPymWQO9VhhZxWz0HOr7sMdXb3aY=;
        b=tS9TEtc+CqAZ1ItSstZ4lyNjTUublsdEkjQe715lMlbB51GLQZocU9MkAh5i0IVS3k
         GmwaSIyk0hORuYjCCjOwvFoGs432fOjAMnbNqx/mpY3afGeuYixBdsJyWArFqv/mbw5i
         xHsMUmjqChxM/SDudYkTGwFr+SOj86NAy/zeI+6uBp0wa7qMjQWWhxk3GX9j2lMeKenO
         4dWluiPCwTzzzyrSYtez3Da2q7VDZ9EdnzbuMV2WGAd9Ka9NotrtMOmS3sbmx6rUzMGh
         IKDHV1emZs4TrB3qEZF1aleTtghz9z6ANFZGsyfp+nV4xPGydRQyIpdDRwV9BH5vdXe/
         eTrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d31si6273902pld.161.2019.02.06.08.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:22:17 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 295922175B;
	Wed,  6 Feb 2019 16:22:15 +0000 (UTC)
Date: Wed, 6 Feb 2019 11:22:13 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas
 Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit
 <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter
 Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
 linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
 akpm@linux-foundation.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org,
 kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit
 <namit@vmware.com>
Subject: Re: [PATCH 08/17] x86/ftrace: set trampoline pages as executable
Message-ID: <20190206112213.2ec9dd5c@gandalf.local.home>
In-Reply-To: <20190117003259.23141-9-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-9-rick.p.edgecombe@intel.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2019 16:32:50 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> From: Nadav Amit <namit@vmware.com>
> 
> Since alloc_module() will not set the pages as executable soon, we need
> to do so for ftrace trampoline pages after they are allocated.
> 
> For the time being, we do not change ftrace to use the text_poke()
> interface. As a result, ftrace breaks still breaks W^X.
> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/ftrace.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
> index 8257a59704ae..eb4a1937e72c 100644
> --- a/arch/x86/kernel/ftrace.c
> +++ b/arch/x86/kernel/ftrace.c
> @@ -742,6 +742,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  	unsigned long end_offset;
>  	unsigned long op_offset;
>  	unsigned long offset;
> +	unsigned long npages;
>  	unsigned long size;
>  	unsigned long retq;
>  	unsigned long *ptr;
> @@ -774,6 +775,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  		return 0;
>  
>  	*tramp_size = size + RET_SIZE + sizeof(void *);
> +	npages = DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
>  
>  	/* Copy ftrace_caller onto the trampoline memory */
>  	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
> @@ -818,6 +820,13 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  	/* ALLOC_TRAMP flags lets us know we created it */
>  	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
>  
> +	/*
> +	 * Module allocation needs to be completed by making the page
> +	 * executable. The page is still writable, which is a security hazard,
> +	 * but anyhow ftrace breaks W^X completely.
> +	 */

Perhaps we should set the page to non writable after the page is
updated? And set it to writable only when we need to update it.

As for this patch:

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

> +	set_memory_x((unsigned long)trampoline, npages);
> +
>  	return (unsigned long)trampoline;
>  fail:
>  	tramp_free(trampoline, *tramp_size);

