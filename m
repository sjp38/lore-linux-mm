Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 235E06B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:32:28 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so2336816pbb.36
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 07:32:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id cx4si9942980pbc.119.2013.11.18.07.32.25
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 07:32:26 -0800 (PST)
Date: Mon, 18 Nov 2013 10:32:11 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
Message-ID: <20131118153211.GB32168@redhat.com>
References: <20131114180455.GA32212@anatevka.fc.hp.com>
 <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
 <20131115005049.GJ5116@anatevka.fc.hp.com>
 <20131115062417.GB9237@gmail.com>
 <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
 <5285C639.5040203@zytor.com>
 <20131115140738.GB6637@redhat.com>
 <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
 <20131115180324.GD6637@redhat.com>
 <CAE9FiQU_OstEq3VWwBB879O4EY0DE+zVWVens+w0MLFUQmr3sw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQU_OstEq3VWwBB879O4EY0DE+zVWVens+w0MLFUQmr3sw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 15, 2013 at 02:24:25PM -0800, Yinghai Lu wrote:
> On Fri, Nov 15, 2013 at 10:03 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> > On Fri, Nov 15, 2013 at 09:33:41AM -0800, Yinghai Lu wrote:
> 
> >> I have one system with 6TiB memory, kdump does not work even
> >> crashkernel=512M in legacy mode. ( it only work on system with
> >> 4.5TiB).
> >
> > Recently I tested one system with 6TB of memory and dumped successfully
> > with 512MB reserved under 896MB. Also I have heard reports of successful
> > dump of 12TB system with 512MB reserved below 896MB (due to cyclic
> > mode of makedumpfile).
> >
> > So with newer releases only reason one might want to reserve more
> > memory is that it might provide speed benefits. We need more testing
> > to quantify this.
> 
> You may need bunch of PCIe cards installed.
> 
> The system with 6TiB + 16 PCIe cards, second kernel OOM.
> The system with 4.5TiB + 16 PCIe cards, second kernel works with vmcore dumped.

What's the distro you are testing with? Do you have latest bits of
makeudmpfile where we use cyclic mode by default and one does not need
more reserved memory because of more physical memory present in the
box. I suspect that might be the problem in your testing environment
and old makedumpfile wil try to allocate larger memory on large
RAM machines and OOM.

[..]
> > So issue remains that crashkernel=X,high is not a good default choice
> > because it consumes extra 72M which we don't have to.
> 
> then if it falls into 896~4G, user may still need to update kexec-tools ?

Yep. But distributions control the version of kexec-tools and version
of kernel and can ship updated kexec-tools by default.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
