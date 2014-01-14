Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id F21C56B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:26:41 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so5283215qaq.29
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 07:26:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si1042270qar.171.2014.01.14.07.26.40
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 07:26:41 -0800 (PST)
Date: Tue, 14 Jan 2014 10:26:27 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] x86, acpi memory hotplug, add parameter to disable
 memory hotplug
Message-ID: <20140114152627.GD3096@redhat.com>
References: <1389650161-13292-1-git-send-email-prarit@redhat.com>
 <CAHGf_=pX303E6VAhL+gApSQ1OsEQHqTuCN8ZSdD3E54YAcFQKA@mail.gmail.com>
 <52D47999.5080905@redhat.com>
 <52D48EC4.5070400@jp.fujitsu.com>
 <1389663689.1792.268.camel@misato.fc.hp.com>
 <52D519EB.3040709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D519EB.3040709@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Dave Young <dyoung@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 14, 2014 at 06:05:15AM -0500, Prarit Bhargava wrote:

[..]
> >>> As mentioned, self-NAK.  I have seen a system that I needed to specify
> >>> memmap=exactmap & had hotplug memory.  I will only keep the acpi_no_memhotplug
> >>> option in the next version of the patch.
> >>
> >>
> >> Your following first patch is simply and makes sense.
> >>
> >> http://marc.info/?l=linux-acpi&m=138922019607796&w=2
> >>
> > 
> > In this option, it also requires changing kexec-tools to specify the new
> > option for kdump.  It won't be simpler.
> 
> It will be simpler for the kernel and those of us who have to debug busted e820
> maps ;)
> 
> Unfortunately I may not be able to give you the automatic disable.  I did
> contemplate adding a !is_kdump_kernel() to the ACPI memory hotplug init call,
> but it seems like that is unacceptable as well.

I think everybody agrees that there has to be a stand alone command line
option to disable memory hotplug.

Whether to tie it into memmap=exactmap and mem=X is the contentious bit.
So I would suggest that just post a patch to disable memory hotplut using
a command line and later more patches can go in if people strongly feel
the need to tie it into memmap=exactmap.

In the mean time, we will modify /etc/sysconfig/kdump to pass
acpi_no_memhotplug so that user does not have to worry about passing this
parameter and kexec-tools will not have to be modified either.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
