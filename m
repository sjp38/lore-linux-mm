Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32F10C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:24:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C657020818
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:24:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C657020818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246A26B0003; Mon, 15 Apr 2019 09:24:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F7436B0006; Mon, 15 Apr 2019 09:24:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BD836B0007; Mon, 15 Apr 2019 09:24:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E47A06B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:24:02 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d8so14594612qkk.17
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:24:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+SLll01yBHllfUOVs3NqbKQkltF6gYfVTKqMwJidOsY=;
        b=EQjN7DPqFxi2Mm6sTorYW5Ugjn/rNAv0h1/79la4EE2rV/QYbW5nYBXnKqckWnHe77
         BqQmx6LDyg2hV1OrtB/+XfjMG7jHF745T2BMRxB502aotMb9rs8Dx0izDKrwKGl83K+y
         zTZHG4sjAkgbXgcsheFZ/9b1tlB2U58I7yU2kM7iUSzwtAvQrINzSyoEga9GVW6UcPga
         V2WZUOQ3Ygurpm3bm129Ht4eDbmNOTAzhQwUv9IDOHLonlEmoDdY9/10PXbaBxT7yz8Y
         Y7qmy7bezUx9qqF04DHBUduWYMSvUBn5BjzuoaM1D5O3rgoxAJp+Ce3C7vSSm7/AFp/i
         myaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKcZOfsi5ulCxiaoycsLD6FSIxmS8Z5JrUo+Cj3SJPEfeg/L0S
	2kuwmI+I2oD79Xgza9EERMglVyHWPRgW0kzVDetN3O70xkViVN5M3oYR0n5gchzPYSHtziZVWrO
	5nQV4lf985xulfki7Bjc6TVZ2NT+O09j+T+Ckqmkqh8cLSCQ2SX25FJhQ+XWg77jPgA==
X-Received: by 2002:a0c:8957:: with SMTP id 23mr60198902qvq.92.1555334642605;
        Mon, 15 Apr 2019 06:24:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEmjwxhOWhGX/4Acs7EBM82lKWvJ8x/CyOj0flmGUpaCNbWattdsnmXVmYMmXMxgCulLGP
X-Received: by 2002:a0c:8957:: with SMTP id 23mr60198835qvq.92.1555334641822;
        Mon, 15 Apr 2019 06:24:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555334641; cv=none;
        d=google.com; s=arc-20160816;
        b=J+eXr+WtBg8v8S8ES5sZLz2KgD1SOzEiCZmnIz2KkeopeFnigRkSszOOCcQxL4/B3s
         bvLtbih9Orl6s2yn7AUGfUgVS7iFPE+aA5sqhevozbp280wXoWxBJ93hyFlCfMGlIfBO
         jMxhcJO06r+B6OTnU16ekIusnbCAAABHFvPRU77MTBGHnI9UIPJv8h2Yc23XFRi/2jWN
         ue9ZwBBOzDUe7DTPSAAVR3bSMuwRx49eNaGPS3KfxchOyah7V6BBEXjaPoaECa3CYQrl
         +3IYHdlFvUVhBG5e25CZ9TGystkO44VWBKWxnq5YEvDmVRaIlKR/Q0OwDWmYFTCdgMr8
         DGvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+SLll01yBHllfUOVs3NqbKQkltF6gYfVTKqMwJidOsY=;
        b=h5GOZ53vKspBY8N672UAzXvRnWuOHLaPNtlRkf2sQ1RW9b5B+2vM83VinGGnRWA5wC
         /pEdAb1uyRzoDFrm9oLh/WadEv6N6mg/dRtQrzpwrL374WfGHLCYfiB9tOpITR5PBodY
         L2g4abLPHCnmIYoT6GY3F8dma+l7/rT5vWR7UmHIUaGF2dzOKLRUCTCZOBodRgtACJcl
         y6tmDjqGSW2E/7p2YKlajo5spdj07kbTElrm1F/aI8tdBgNZaoz7LW4cLpxdk6dJFg6M
         V0lAkNnPUyReaUwooJEfKxoqacbQYbuJoaGZuAv2rpa9bYYqkXXRDKqXZHzoOYW/2o+G
         jedQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r2si3053783qkd.62.2019.04.15.06.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 06:24:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9CBAB3092648;
	Mon, 15 Apr 2019 13:23:47 +0000 (UTC)
Received: from treble (ovpn-120-105.rdu2.redhat.com [10.10.120.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9B92060150;
	Mon, 15 Apr 2019 13:23:43 +0000 (UTC)
Date: Mon, 15 Apr 2019 08:23:39 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
Message-ID: <20190415132339.wiqyzygqklliyml7@treble>
References: <20190414155936.679808307@linutronix.de>
 <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 15 Apr 2019 13:23:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 11:02:58AM +0200, Thomas Gleixner wrote:
> kstack_end() is broken on interrupt stacks as they are not guaranteed to be
> sized THREAD_SIZE and THREAD_SIZE aligned.
> 
> Use the stack tracer instead. Remove the pointless pointer increment at the
> end of the function while at it.
> 
> Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: linux-mm@kvack.org
> ---
> V4: Made the code simpler to understand (Andy) and make it actually compile
> ---
>  mm/slab.c |   30 ++++++++++++++----------------
>  1 file changed, 14 insertions(+), 16 deletions(-)
> 
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1470,33 +1470,31 @@ static bool is_debug_pagealloc_cache(str
>  static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
>  			    unsigned long caller)
>  {
> -	int size = cachep->object_size;
> +	int size = cachep->object_size / sizeof(unsigned long);
>  
>  	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
>  
> -	if (size < 5 * sizeof(unsigned long))
> +	if (size < 5)
>  		return;
>  
>  	*addr++ = 0x12345678;
>  	*addr++ = caller;
>  	*addr++ = smp_processor_id();
> -	size -= 3 * sizeof(unsigned long);
> +	size -= 3;
> +#ifdef CONFIG_STACKTRACE
>  	{
> -		unsigned long *sptr = &caller;
> -		unsigned long svalue;
> -
> -		while (!kstack_end(sptr)) {
> -			svalue = *sptr++;
> -			if (kernel_text_address(svalue)) {
> -				*addr++ = svalue;
> -				size -= sizeof(unsigned long);
> -				if (size <= sizeof(unsigned long))
> -					break;
> -			}
> -		}
> +		struct stack_trace trace = {
> +			/* Leave one for the end marker below */
> +			.max_entries	= size - 1,
> +			.entries	= addr,
> +			.skip		= 3,
> +		};
>  
> +		save_stack_trace(&trace);
> +		addr += trace.nr_entries;
>  	}
> -	*addr++ = 0x87654321;
> +#endif
> +	*addr = 0x87654321;

Looks like stack_trace.nr_entries isn't initialized?  (though this code
gets eventually replaced by a later patch)

Who actually reads this stack trace?  I couldn't find a consumer.

-- 
Josh

