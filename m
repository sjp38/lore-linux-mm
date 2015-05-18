Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 48ED16B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 16:40:31 -0400 (EDT)
Received: by yhda23 with SMTP id a23so54646659yhd.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 13:40:31 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id l48si6574288yhl.57.2015.05.18.13.40.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 13:40:30 -0700 (PDT)
Message-ID: <1431980468.21019.11.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 18 May 2015 14:21:08 -0600
In-Reply-To: <20150518200114.GE23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
	 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	 <20150518133348.GA23618@pd.tnic>
	 <1431969759.19889.5.camel@misato.fc.hp.com>
	 <20150518190150.GC23618@pd.tnic>
	 <1431977519.20569.15.camel@misato.fc.hp.com>
	 <20150518200114.GE23618@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Mon, 2015-05-18 at 22:01 +0200, Borislav Petkov wrote:
> On Mon, May 18, 2015 at 01:31:59PM -0600, Toshi Kani wrote:
> > Well, #2 and #3 are independent. That is, uniform can be set regardless
> 
> Not #2 and #3 above - the original #2 and #3 ones. I've written them out
> detailed to show what I mean.

The original #2 and #3 are set independently as well. They do not depend
on each other condition being a specific value.

> > The caller is responsible for verifying the conditions that are safe to
> > create huge page.
> 
> How is the caller ever going to be able to do anything about it?

The caller is the one who makes the condition checks necessary to create
a huge page mapping.  mtrr_type_look() only returns how the given range
is related with MTRRs.

> Regardless, I'd prefer to not duplicate comments and rather put a short
> sentence pointing the reader to the comments over mtrr_type_lookup()
> where this all is being explained in detail.
> 
> I'll fix it up.

I appreciate your help.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
