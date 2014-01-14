Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC406B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:59:58 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id a11so1391177qen.10
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:59:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si969882qar.139.2014.01.14.06.59.56
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 06:59:57 -0800 (PST)
Date: Tue, 14 Jan 2014 09:36:18 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] x86, acpi memory hotplug, add parameter to disable
 memory hotplug
Message-ID: <20140114143618.GA3096@redhat.com>
References: <1389650161-13292-1-git-send-email-prarit@redhat.com>
 <CAHGf_=pX303E6VAhL+gApSQ1OsEQHqTuCN8ZSdD3E54YAcFQKA@mail.gmail.com>
 <52D47999.5080905@redhat.com>
 <52D48EC4.5070400@jp.fujitsu.com>
 <1389663689.1792.268.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389663689.1792.268.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Dave Young <dyoung@redhat.com>, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 13, 2014 at 06:41:29PM -0700, Toshi Kani wrote:
> On Tue, 2014-01-14 at 10:11 +0900, Yasuaki Ishimatsu wrote:
>  :
> > >> I think we need a knob manually enable mem-hotplug when specify memmap. But
> > >> it is another story.
> > >>
> > >> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > >
> > > As mentioned, self-NAK.  I have seen a system that I needed to specify
> > > memmap=exactmap & had hotplug memory.  I will only keep the acpi_no_memhotplug
> > > option in the next version of the patch.
> > 
> > 
> > Your following first patch is simply and makes sense.
> > 
> > http://marc.info/?l=linux-acpi&m=138922019607796&w=2
> > 
> 
> In this option, it also requires changing kexec-tools to specify the new
> option for kdump.  It won't be simpler.

I am thinking that instead of modifying kexec-tools, it can be made
part of the documentation so that user is expected to pass this parameter.

In fedora, we can modify /etc/sysconfig/kdump and add the parameter by
default so that user's don't have to worry about passing it.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
