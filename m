Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7152D6B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 05:16:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so86903298lfi.0
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 02:16:48 -0700 (PDT)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id i83si2439436wma.27.2016.07.16.02.16.46
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 02:16:46 -0700 (PDT)
Date: Sat, 16 Jul 2016 11:15:43 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3.10.y 04/12] x86/mm: Add barriers and document
 switch_mm()-vs-flush synchronization
Message-ID: <20160716091543.GA22375@1wt.eu>
References: <1468607194-3879-1-git-send-email-ciwillia@brocade.com>
 <1468607194-3879-4-git-send-email-ciwillia@brocade.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468607194-3879-4-git-send-email-ciwillia@brocade.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Charles (Chas) Williams" <ciwillia@brocade.com>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Luis Henriques <luis.henriques@canonical.com>

Hi Chas,

On Fri, Jul 15, 2016 at 02:26:26PM -0400, Charles (Chas) Williams wrote:
> From: Andy Lutomirski <luto@kernel.org>
> 
> commit 71b3c126e61177eb693423f2e18a1914205b165e upstream.
> 
> When switch_mm() activates a new PGD, it also sets a bit that
> tells other CPUs that the PGD is in use so that TLB flush IPIs
> will be sent.  In order for that to work correctly, the bit
> needs to be visible prior to loading the PGD and therefore
> starting to fill the local TLB.
> 
> Document all the barriers that make this work correctly and add
> a couple that were missing.
> 
> CVE-2016-2069

I'm fine with queuing these patches for 3.10, but patches 4, 9 and 12
of your series are not in 3.14, and I only apply patches to 3.10 if
they are already present in 3.14 (or if there's a good reason of course).
Please could you check that you already submitted them ? If so I'll just
wait for them to pop up there. It's important for us to ensure that users
upgrading from extended LTS kernels to normal LTS kernels are never hit
by a bug that was previously fixed in the older one and not yet in the
newer one.

Thanks,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
