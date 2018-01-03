Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B95D6B049A
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 18:46:16 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g26so11149wrb.8
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 15:46:15 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id r8si1340631wma.59.2018.01.03.15.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 15:46:14 -0800 (PST)
Date: Thu, 4 Jan 2018 00:46:08 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <0694E863-477E-45D1-AFE0-DE26933553FB@amacapital.net>
Message-ID: <alpine.DEB.2.20.1801040045510.1957@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180103154833.fhkbwonz6zhm26ax@gmail.com> <20180103223222.GA22901@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801032334180.1957@nanos> <20180103224902.GB22901@trogon.sfo.coreos.systems> <alpine.DEB.2.20.1801032355330.1957@nanos> <alpine.DEB.2.20.1801032358200.1957@nanos> <0694E863-477E-45D1-AFE0-DE26933553FB@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 3 Jan 2018, Andy Lutomirski wrote:
> > On Jan 3, 2018, at 2:58 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> On Wed, 3 Jan 2018, Thomas Gleixner wrote:
> >> 
> >>> On Wed, 3 Jan 2018, Benjamin Gilbert wrote:
> >>>> On Wed, Jan 03, 2018 at 11:34:46PM +0100, Thomas Gleixner wrote:
> >>>> Can you please send me your .config and a full dmesg ?
> >>> 
> >>> I've attached a serial log from a local QEMU.  I can rerun with a higher
> >>> loglevel if need be.
> >> 
> >> Thanks!
> >> 
> >> Cc'ing Andy who might have an idea and he's probably more away than I
> > 
> > s/away/awake/ just to demonstrate the state I'm in ...
> > 
> >> am. Will have a look tomorrow if Andy does not beat me to it.
> 
> Can you forward me more of the thread?

On the way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
