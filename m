Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C59176B04A6
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:37:41 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w18so62379wra.5
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:37:41 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id j20si1388404wmc.224.2018.01.03.16.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 16:37:40 -0800 (PST)
Date: Thu, 4 Jan 2018 01:37:39 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <20180104003303.GA1654@trogon.sfo.coreos.systems>
Message-ID: <alpine.DEB.2.20.1801040136390.1957@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180104003303.GA1654@trogon.sfo.coreos.systems>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 3 Jan 2018, Benjamin Gilbert wrote:

> On Wed, Jan 03, 2018 at 10:20:16AM +0100, Greg Kroah-Hartman wrote:
> > Ick, not good, any chance you can test 4.15-rc6 to verify that the issue
> > is also there (or not)?
> 
> I haven't been able to reproduce this on 4.15-rc6.

Hmm. So we need to scrutinize the subtle differences between 4.15-rc6 and 4.14.11....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
