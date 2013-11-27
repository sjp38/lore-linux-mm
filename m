Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0729E6B0036
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 20:07:50 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id hz11so4294500vcb.17
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:07:50 -0800 (PST)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id pu5si20259387veb.97.2013.11.26.17.07.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 17:07:50 -0800 (PST)
Received: by mail-vc0-f176.google.com with SMTP id lf12so4325227vcb.21
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:07:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <529540FE.3070504@zytor.com>
References: <20131121132041.GS4138@linux.vnet.ibm.com>
	<20131121172558.GA27927@linux.vnet.ibm.com>
	<20131121215249.GZ16796@laptop.programming.kicks-ass.net>
	<20131121221859.GH4138@linux.vnet.ibm.com>
	<20131122155835.GR3866@twins.programming.kicks-ass.net>
	<20131122182632.GW4138@linux.vnet.ibm.com>
	<20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	<20131125173540.GK3694@twins.programming.kicks-ass.net>
	<20131125180250.GR4138@linux.vnet.ibm.com>
	<5293E37F.5020908@zytor.com>
	<20131126031626.GE4138@linux.vnet.ibm.com>
	<529540FE.3070504@zytor.com>
Date: Tue, 26 Nov 2013 17:07:49 -0800
Message-ID: <CA+55aFygj=JQkFf7-tW4CxXsECqYqxVeDva4gvBttu75-x0dOQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Nov 26, 2013 at 4:46 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> The best pointer I can give is the example in section 8.2.3.6 of the
> current SDM (version 048, dated September 2013).  It is a bit more
> complex than what you have described above.

That 8.2.3.6 thing (and the whole "causally related" argument) does
seem to say that the MCS lock is fine on x86 without any extra
barriers. My A < B .. < F < A argument was very much a causality-based
one.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
