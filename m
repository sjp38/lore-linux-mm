Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AAACC10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65CE820880
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65CE820880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F13FD6B0003; Mon, 15 Apr 2019 12:08:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC2316B0006; Mon, 15 Apr 2019 12:08:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB10F6B0007; Mon, 15 Apr 2019 12:08:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9195C6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 12:08:07 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y189so15800727wmd.4
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:08:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=Dh2AZU7RpcP/Ek7fWjPn3FxJ/AldwYEyS5Dy8/Z1ohM=;
        b=ZNBlRsuMnncMZ000rnMlR+7/PXemOsvx3DunHOfaQ+n4NUkSGxS7fUvWLsj+qqOtdP
         C6pxL+IjdAtReKOw4CcqtAW8eGiNviToX1civwVm6LNhKqjZDv2ISgvx3MHuFg8P3K/4
         gvCtkydsf1s9XrNYSHQOX6IBwj0LQlzSvNxi9at952m7tLMmZie0K/bRYKoaiBE05mu2
         Il0AhzXPe2cLgvjyiJi+TeiQh7x1G173pEmXPvmXiZk/cMvA3wiRVcZ7OvUd8f7TLMgH
         RJjaFwvF2Nw94StBibT3XZ6ZSiudBTlapNbLCwdC/7/CdGyExIaRBFsWBOJxb6hd7Tbd
         glnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWgDyS6Yc6c0brWrjAYePTjHldZF01g7zUR6bxcgxZsc7DpXgl9
	/llGXgsNTt4lBXYsZr5Zi1cSU9mxAjI8pcNDxiScaNzmXzNq9194nxKuukuvbCb8REdrH/k77+c
	LVRU1hEH+uAKQdS05WO4GgrDwvLeyVNhFbfLHWTiLbIFtqHFUIVbumV/LvuUiEV5jFg==
X-Received: by 2002:a1c:3104:: with SMTP id x4mr21861337wmx.23.1555344486955;
        Mon, 15 Apr 2019 09:08:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwg5nHBL+tjdRvmfuFy9s0BXvKfE0lgYlP0ZwpnkV+npbVTZ+hTKeasuViDKFWyY50ASyD3
X-Received: by 2002:a1c:3104:: with SMTP id x4mr21860976wmx.23.1555344481251;
        Mon, 15 Apr 2019 09:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555344481; cv=none;
        d=google.com; s=arc-20160816;
        b=zkfwlEx83D/RXi+kEIfhaEDUqU7L2T/22p4xhVLC6/RoGLeRi91xX1OR/DVALbxqdI
         71VPxoloSdp9/sI7vJdD27h/TKnH/p3aRmtK5FvQ01I++PqALsAx34ENNs3O5T8EngbQ
         QLCtnn3tgfhgALY0I5GiUydtqHGo5UhAOJ+2UH2XOz+ct98w0Ig0hLfjPYOD65xEWeL+
         HZPyL5tZmoeqSPpwWRqnfF+lHGqEEV+4U2LDCCOgodJ0UxBs7zsQymq7rofg2XHZXlER
         eapBMMPJg4oe0l0vvo/IMBaiCNNbdNDKw9al44GMxmazOVbPCc9RGcOxcb8/aOOx9dg8
         qHsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=Dh2AZU7RpcP/Ek7fWjPn3FxJ/AldwYEyS5Dy8/Z1ohM=;
        b=JreP2S04KPQdAJ9HKGdWfcOzHOXxHgzNAh0SySxiUOe/KDFmBeYa/MUMvwdwadD/2R
         dttvzEKFXHUmdW9VPuYq1+cLJPZ/HwfjcLpGXSqbUL8O/xPDuWIlHBFBkD8eApqYiSef
         nORnPGLCrbCiS3mp8J2iF98kVRAQYe0teLJh62FWGF5wxP94NqDg7ejTJXMWnpCGlquv
         obj2jXjTQA32Lbx2894h1nIA2OnEaVWMF4XxhqkLb3rBuUkbcLBCe2KHOBvLEczKx25q
         7xgrsW4x0VSd7E6MiJHMdhJL0+GcTWVKBdfcXHD5ucnKdi7qMJMvtB6vRm93pbguu1xW
         x8+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f138si11377071wme.186.2019.04.15.09.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Apr 2019 09:08:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hG497-0004wf-Ez; Mon, 15 Apr 2019 18:07:49 +0200
Date: Mon, 15 Apr 2019 18:07:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
    X86 ML <x86@kernel.org>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
In-Reply-To: <20190415132339.wiqyzygqklliyml7@treble>
Message-ID: <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de> <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Apr 2019, Josh Poimboeuf wrote:
> On Mon, Apr 15, 2019 at 11:02:58AM +0200, Thomas Gleixner wrote:
> >  	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
> >  
> > -	if (size < 5 * sizeof(unsigned long))
> > +	if (size < 5)
> >  		return;
> >  
> >  	*addr++ = 0x12345678;
> >  	*addr++ = caller;
> >  	*addr++ = smp_processor_id();
> > -	size -= 3 * sizeof(unsigned long);
> > +	size -= 3;
> > +#ifdef CONFIG_STACKTRACE
> >  	{
> > -		unsigned long *sptr = &caller;
> > -		unsigned long svalue;
> > -
> > -		while (!kstack_end(sptr)) {
> > -			svalue = *sptr++;
> > -			if (kernel_text_address(svalue)) {
> > -				*addr++ = svalue;
> > -				size -= sizeof(unsigned long);
> > -				if (size <= sizeof(unsigned long))
> > -					break;
> > -			}
> > -		}
> > +		struct stack_trace trace = {
> > +			/* Leave one for the end marker below */
> > +			.max_entries	= size - 1,
> > +			.entries	= addr,
> > +			.skip		= 3,
> > +		};
> >  
> > +		save_stack_trace(&trace);
> > +		addr += trace.nr_entries;
> >  	}
> > -	*addr++ = 0x87654321;
> > +#endif
> > +	*addr = 0x87654321;
> 
> Looks like stack_trace.nr_entries isn't initialized?  (though this code
> gets eventually replaced by a later patch)

struct initializer initialized the non mentioned fields to 0, if I'm not
totally mistaken.

> Who actually reads this stack trace?  I couldn't find a consumer.

It's stored directly in the memory pointed to by @addr and that's the freed
cache memory. If that is used later (UAF) then the stack trace can be
printed to see where it was freed.

Thanks,

	tglx

