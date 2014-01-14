Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id D2D0F6B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:51:49 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so4913735qcx.38
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:51:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hj7si25591612qeb.78.2014.01.13.17.51.48
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 17:51:49 -0800 (PST)
Date: Tue, 14 Jan 2014 09:52:02 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory
 mapping is specified by user [v2]
Message-ID: <20140114015202.GD4327@dhcp-16-126.nay.redhat.com>
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>
 <1389380698-19361-4-git-send-email-prarit@redhat.com>
 <alpine.DEB.2.02.1401111624170.20677@be1.lrz>
 <52D32962.5050908@redhat.com>
 <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>
 <52D4793E.8070102@redhat.com>
 <1389659632.1792.247.camel@misato.fc.hp.com>
 <52D48A9D.7000003@zytor.com>
 <1389661746.1792.254.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389661746.1792.254.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bodo Eggert <7eggert@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/13/14 at 06:09pm, Toshi Kani wrote:
> On Mon, 2014-01-13 at 16:53 -0800, H. Peter Anvin wrote:
> > On 01/13/2014 04:33 PM, Toshi Kani wrote:
> > > 
> > > I do not think it makes sense.  You needed memmap=exactmap as a
> > > workaround because the kernel did not boot with the firmware's memory
> > > info.  So, it's broken, and you requested the kernel to ignore the
> > > firmware info.
> > > 
> > > Why do you think memory hotplug needs to be supported under such
> > > condition, which has to use the broken firmware info?
> > > 
> > 
> > Even more than memory hotplug: what do we do with NUMA?  Since we have
> > already told the kernel "the firmware is bogus" it would seem that any
> > NUMA optimizations would be a bit ... cantankerous at best, no?
> 
> Agreed that NUMA info can be bogus in this case, but is probably not
> critical.
> 
> In majority of the cases, memmap=exactmap is used for kdump and the
> firmware info is sane.  So, I think we should keep NUMA enabled since it
> could be useful when multiple CPUs are enabled for kdump.

In Fedora kdump, we by default add numa=off to 2nd kernel cmdline because
enabling numa will use a lot more memory, at the same time we have only 128M
reserved by default..

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
