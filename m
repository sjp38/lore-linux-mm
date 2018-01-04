Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBD0A6B04AA
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:38:34 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id m43so63628otb.7
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:38:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u64sor713028oif.39.2018.01.03.16.38.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 16:38:34 -0800 (PST)
Date: Wed, 3 Jan 2018 16:38:30 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104003830.GB1654@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180103154833.fhkbwonz6zhm26ax@gmail.com>
 <20180103223222.GA22901@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801032334180.1957@nanos>
 <20180103224902.GB22901@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801032355330.1957@nanos>
 <alpine.DEB.2.20.1801032358200.1957@nanos>
 <69DD36C3-193E-4DCA-91A6-915BF3B434F7@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69DD36C3-193E-4DCA-91A6-915BF3B434F7@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 03, 2018 at 04:27:04PM -0800, Andy Lutomirski wrote:
> How much memory does the affected system have?  It sounds like something
> is mapped in the LDT region and is getting corrupted because the LDT code
> expects to own that region.

We've seen this on systems from 1 to 7 GB.

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
