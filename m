Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0526882F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 09:52:49 -0400 (EDT)
Received: by obctp1 with SMTP id tp1so44130618obc.2
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 06:52:48 -0700 (PDT)
Received: from g1t6216.austin.hp.com (g1t6216.austin.hp.com. [15.73.96.123])
        by mx.google.com with ESMTPS id ru10si4435861obb.2.2015.10.30.06.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 06:52:48 -0700 (PDT)
Message-ID: <1446212931.20657.161.camel@hpe.com>
Subject: Re: [PATCH v2 UPDATE-2 3/3] ACPI/APEI/EINJ: Allow memory error
 injection to NVDIMM
From: Toshi Kani <toshi.kani@hpe.com>
Date: Fri, 30 Oct 2015 07:48:51 -0600
In-Reply-To: <20151030094029.GC20952@pd.tnic>
References: <1445894544-21382-1-git-send-email-toshi.kani@hpe.com>
	 <20151030094029.GC20952@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: tony.luck@intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 2015-10-30 at 10:40 +0100, Borislav Petkov wrote:
> On Mon, Oct 26, 2015 at 03:22:24PM -0600, Toshi Kani wrote:
> > @@ -545,10 +545,15 @@ static int einj_error_inject(u32 type, u32 flags, u64
> > param1, u64 param2,
> >  	/*
> >  	 * Disallow crazy address masks that give BIOS leeway to pick
> >  	 * injection address almost anywhere. Insist on page or
> > -	 * better granularity and that target address is normal RAM.
> > +	 * better granularity and that target address is normal RAM or
> > +	 * NVDIMM.
> >  	 */
> > -	pfn = PFN_DOWN(param1 & param2);
> > -	if (!page_is_ram(pfn) || ((param2 & PAGE_MASK) != PAGE_MASK))
> > +	base_addr = param1 & param2;
> > +	size = (~param2) + 1;
> 
> Hmm, I missed this last time: why are the brackets there?
> 
> AFAIK, bitwise NOT has a higher precedence than addition.

Yes, the brackets are not necessary.  I put them as self-explanatory of the
precedence.  Shall I remove them, and send you an updated patch?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
