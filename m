Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3642E6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 04:18:08 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id cc10so380912wib.0
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:18:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dm7si1494585wib.95.2014.09.12.01.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 01:18:06 -0700 (PDT)
Date: Fri, 12 Sep 2014 10:17:54 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v8 06/10] mips: sync struct siginfo with general
 version
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE017A3FF0@shsmsx102.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.10.1409121015070.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-7-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120007550.4178@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE017A3FF0@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 12 Sep 2014, Ren, Qiaowei wrote:
> On 2014-09-12, Thomas Gleixner wrote:
> > On Thu, 11 Sep 2014, Qiaowei Ren wrote:
> > 
> >> Due to new fields about bound violation added into struct siginfo,
> >> this patch syncs it with general version to avoid build issue.
> > 
> > You completely fail to explain which build issue is addressed by this
> > patch. The code you added to kernel/signal.c which accesses _addr_bnd
> > is guarded by
> > 
> > +#ifdef SEGV_BNDERR
> > 
> > which is not defined my MIPS. Also why is this only affecting MIPS and
> > not any other architecture which provides its own struct siginfo ?
> > 
> > That patch makes no sense at all, at least not without a proper explanation.
> >
> For arch=mips, siginfo.h (arch/mips/include/uapi/asm/siginfo.h) will
> include general siginfo.h, and only replace general stuct siginfo
> with mips specific struct siginfo. So SEGV_BNDERR will be defined
> for all archs, and we will get error like "no _lower in struct
> siginfo" when arch=mips.

> In addition, only MIPS arch define its own struct siginfo, so this
> is only affecting MIPS.

So IA64 does not count as an architecture and therefor does not need
the same treatment, right?

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
