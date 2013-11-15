Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B2CF26B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:24:29 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so1949824pde.35
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:24:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id bq8si3116435pab.290.2013.11.15.14.24.26
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 14:24:27 -0800 (PST)
Received: by mail-ie0-f169.google.com with SMTP id tp5so5855129ieb.28
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:24:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131115180324.GD6637@redhat.com>
References: <20131113235708.GC25344@anatevka.fc.hp.com>
	<CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>
	<20131114180455.GA32212@anatevka.fc.hp.com>
	<CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
	<20131115005049.GJ5116@anatevka.fc.hp.com>
	<20131115062417.GB9237@gmail.com>
	<CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
	<5285C639.5040203@zytor.com>
	<20131115140738.GB6637@redhat.com>
	<CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
	<20131115180324.GD6637@redhat.com>
Date: Fri, 15 Nov 2013 14:24:25 -0800
Message-ID: <CAE9FiQU_OstEq3VWwBB879O4EY0DE+zVWVens+w0MLFUQmr3sw@mail.gmail.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 15, 2013 at 10:03 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Fri, Nov 15, 2013 at 09:33:41AM -0800, Yinghai Lu wrote:

>> I have one system with 6TiB memory, kdump does not work even
>> crashkernel=512M in legacy mode. ( it only work on system with
>> 4.5TiB).
>
> Recently I tested one system with 6TB of memory and dumped successfully
> with 512MB reserved under 896MB. Also I have heard reports of successful
> dump of 12TB system with 512MB reserved below 896MB (due to cyclic
> mode of makedumpfile).
>
> So with newer releases only reason one might want to reserve more
> memory is that it might provide speed benefits. We need more testing
> to quantify this.

You may need bunch of PCIe cards installed.

The system with 6TiB + 16 PCIe cards, second kernel OOM.
The system with 4.5TiB + 16 PCIe cards, second kernel works with vmcore dumped.

>
>> --- first kernel can reserve the 512M under 896M, second kernel will
>> OOM as it load driver for every pci devices...
>>
>> So why would RH guys not spend some time on optimizing your kdump initrd
>> build scripts and only put dump device related driver in it?
>
> Try latest Fedora and that's what we do. Now we have moved to dracut
> based initramfs generation and we tell dracut that build initramfs for
> host and additional dump destination and dracut builds it for those only.
> I think there might be scope for further optimization, but I don't think
> that's the problem any more.

Good. Assume that will be in RHEL 7.

>
> So issue remains that crashkernel=X,high is not a good default choice
> because it consumes extra 72M which we don't have to.

then if it falls into 896~4G, user may still need to update kexec-tools ?

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
