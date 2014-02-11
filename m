Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id D7AD06B0035
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:43:39 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id e16so13499973qcx.21
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:43:39 -0800 (PST)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id s22si13135343qge.16.2014.02.11.10.43.38
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 10:43:38 -0800 (PST)
Date: Tue, 11 Feb 2014 12:43:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Memory allocator semantics
In-Reply-To: <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1402111242380.28186@nuc>
References: <20140102203320.GA27615@linux.vnet.ibm.com> <52F60699.8010204@iki.fi> <20140209020004.GY4250@linux.vnet.ibm.com> <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, 11 Feb 2014, Pekka Enberg wrote:

> So again, there's nothing in (A) that the memory allocator is
> concerned about.  kmalloc() makes no guarantees whatsoever about the
> visibility of "r1" across CPUs.  If you're saying that there's an
> implicit barrier between kmalloc() and kfree(), that's an unintended
> side-effect, not a design decision AFAICT.

I am not sure that this side effect necessarily happens. The SLUB fastpath
does not disable interrupts and only uses a cmpxchg without lock
semantics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
