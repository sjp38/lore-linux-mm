Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 758F26B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 03:50:26 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so7326967pab.26
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 00:50:26 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id qx4si18242970pbc.75.2014.02.11.00.50.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 00:50:25 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so7409744pad.0
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 00:50:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140209020004.GY4250@linux.vnet.ibm.com>
References: <20140102203320.GA27615@linux.vnet.ibm.com>
	<52F60699.8010204@iki.fi>
	<20140209020004.GY4250@linux.vnet.ibm.com>
Date: Tue, 11 Feb 2014 10:50:24 +0200
Message-ID: <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
Subject: Re: Memory allocator semantics
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

Hi Paul,

On Sun, Feb 9, 2014 at 4:00 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> From what I can see, (A) works by accident, but is kind of useless because
> you allocate and free the memory without touching it.  (B) and (C) are the
> lightest touches I could imagine, and as you say, both are bad.  So I
> believe that it is reasonable to prohibit (A).
>
> Or is there some use for (A) that I am missing?

So again, there's nothing in (A) that the memory allocator is
concerned about.  kmalloc() makes no guarantees whatsoever about the
visibility of "r1" across CPUs.  If you're saying that there's an
implicit barrier between kmalloc() and kfree(), that's an unintended
side-effect, not a design decision AFAICT.

                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
