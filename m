Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADF6B6B03C1
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 17:34:48 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e128so83291wmg.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 14:34:48 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id e25si1270768wmh.191.2018.01.03.14.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 14:34:47 -0800 (PST)
Date: Wed, 3 Jan 2018 23:34:46 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <20180103223222.GA22901@trogon.sfo.coreos.systems>
Message-ID: <alpine.DEB.2.20.1801032334180.1957@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180103154833.fhkbwonz6zhm26ax@gmail.com>
 <20180103223222.GA22901@trogon.sfo.coreos.systems>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 3 Jan 2018, Benjamin Gilbert wrote:

> On Wed, Jan 03, 2018 at 04:48:33PM +0100, Ingo Molnar wrote:
> > first please test the latest WIP.x86/pti branch which has a couple of fixes.
> 
> I'm still seeing the problem with that branch (3ffdeb1a02be, plus a couple
> of local patches which shouldn't affect the resulting binary).

Can you please send me your .config and a full dmesg ?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
