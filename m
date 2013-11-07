Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E309F6B0148
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 03:25:50 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lf10so264581pab.34
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:25:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.141])
        by mx.google.com with SMTP id zt6si2193567pac.61.2013.11.07.00.25.48
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 00:25:49 -0800 (PST)
Received: by mail-ea0-f180.google.com with SMTP id b11so116146eae.39
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:25:46 -0800 (PST)
Date: Thu, 7 Nov 2013 09:25:41 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
Message-ID: <20131107082541.GA32542@gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
 <1383773827.11046.355.camel@schen9-DESK>
 <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
 <20131107081306.GA32438@gmail.com>
 <CA+55aFzMcEudpr2rXdaD7O70=iMEYUKsjB5tGy=zFKTLiyhXgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzMcEudpr2rXdaD7O70=iMEYUKsjB5tGy=zFKTLiyhXgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Arnd Bergmann <arnd@arndb.de>, Rik van Riel <riel@redhat.com>, Aswin Chandramouleeswaran <aswin@hp.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Figo. zhang" <figo1802@gmail.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, linux-kernel@vger.kernel.org, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> I don't necessarily mind the factoring out, I just think it needs to be 
> really solid and clear if - and *before* - we do this. [...]

Okay, agreed.

> [...] We do *not* want to factor out some half-arsed implementation and 
> then have later patches to fix up the crud. Nor when multiple different 
> locks then use that common code.
> 
> So I think it needs to be *clearly* great code before it gets factored 
> out. Because before it is great code, it should not be shared with 
> anything else.

Ok, we'll go through it with a fine comb and I won't rush merging it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
