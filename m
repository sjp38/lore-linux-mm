Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 09C2E6B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:33:34 -0400 (EDT)
Received: by oica37 with SMTP id a37so147609240oic.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:33:33 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id c123si10258848oib.112.2015.05.05.07.33.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 07:33:33 -0700 (PDT)
Message-ID: <1430835266.23761.251.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 1/7] mm, x86: Document return values of mapping funcs
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 05 May 2015 08:14:26 -0600
In-Reply-To: <20150505141906.GI3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-2-git-send-email-toshi.kani@hp.com>
	 <20150505111913.GH3910@pd.tnic>
	 <1430833596.23761.245.camel@misato.fc.hp.com>
	 <20150505141906.GI3910@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-05 at 16:19 +0200, Borislav Petkov wrote:
> On Tue, May 05, 2015 at 07:46:36AM -0600, Toshi Kani wrote:
> > Agreed.  This patch-set was originally a small set of patches, but was
> > extended later with additional patches, which ended up with touching the
> > same place again.  I will reorganize the patch-set.
> 
> Ok, but please wait until I take a look at the rest.

Sure, I will wait for your review.  

> 
> Thanks.
> 
> Btw, is there anything else MTRR-related pending for tip?

Not exactly MTRR-related, but I am planing to re-submit my WT patchset
after checking to see if Luis's patchset (which you are reviewing) has
any conflict with this.

https://lkml.org/lkml/2015/2/24/773

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
