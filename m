Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECA4C6B0494
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 17:57:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id q12so1516044wrg.13
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 14:57:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id a64si1330422wmd.147.2018.01.03.14.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 14:57:29 -0800 (PST)
Date: Wed, 3 Jan 2018 23:57:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <20180103224902.GB22901@trogon.sfo.coreos.systems>
Message-ID: <alpine.DEB.2.20.1801032355330.1957@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180103154833.fhkbwonz6zhm26ax@gmail.com> <20180103223222.GA22901@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801032334180.1957@nanos> <20180103224902.GB22901@trogon.sfo.coreos.systems>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 3 Jan 2018, Benjamin Gilbert wrote:
> On Wed, Jan 03, 2018 at 11:34:46PM +0100, Thomas Gleixner wrote:
> > Can you please send me your .config and a full dmesg ?
> 
> I've attached a serial log from a local QEMU.  I can rerun with a higher
> loglevel if need be.

Thanks!

Cc'ing Andy who might have an idea and he's probably more away than I
am. Will have a look tomorrow if Andy does not beat me to it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
