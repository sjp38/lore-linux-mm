Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id A7B7B6B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 12:41:10 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id wy17so2676819pbc.25
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 09:41:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.120])
        by mx.google.com with SMTP id kn3si2629378pbc.64.2013.11.15.09.41.07
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 09:41:08 -0800 (PST)
Message-ID: <52865CA1.5020309@zytor.com>
Date: Fri, 15 Nov 2013 09:40:49 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <20131113224503.GB25344@anatevka.fc.hp.com>	<52840206.5020006@zytor.com>	<20131113235708.GC25344@anatevka.fc.hp.com>	<CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>	<20131114180455.GA32212@anatevka.fc.hp.com>	<CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>	<20131115005049.GJ5116@anatevka.fc.hp.com>	<20131115062417.GB9237@gmail.com>	<CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>	<5285C639.5040203@zytor.com>	<20131115140738.GB6637@redhat.com> <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
In-Reply-To: <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Vivek Goyal <vgoyal@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 11/15/2013 09:33 AM, Yinghai Lu wrote:
> 
> If the system support intel IOMMU, we only need to that 72M for SWIOTLB
> or AMD workaround.
> If the user really care that for intel iommu enable system, they could use
> "crashkernel=0,low" to have that 72M back.
> 
> and that 72M is under 4G instead of 896M.
> 
> so reserve 72M is not better than reserve 128M?
> 

Those 72M are in addition to 128M, which does add up quite a bit.
However, the presence of a working IOMMU in the system is something that
should be possible to know at setup time.

Now, this was discussed partly in the context of VMs.  I want to say, as
I have again and again: the right way to dump a VM is with hypervisor
assistance rather than an in-image dumper which is both expensive and
may be corrupted by the failure.

It would be good if the various VMs with interest in Linux would agree
on a mechanism for launching a dumper.  This can be done either inband
(on the execution of a specific hypercall, the hypervisor terminates I/O
to the guest, inserts a dumper into the address space and launches it)
or out-of-band (the hypervisor itself, or an assistant program, writes a
dump file) or as a hybrid (a new dump guest is launched with the
hypervisor-written or hypervisor-preserved crashed guest image somehow
passed to it.)

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
