Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 954556B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 13:16:52 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so3937892pbc.12
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 10:16:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id hk1si2703158pbb.41.2013.11.15.10.16.47
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 10:16:48 -0800 (PST)
Date: Fri, 15 Nov 2013 11:16:41 -0700
From: jerry.hoemann@hp.com
Subject: Re: [PATCH 0/3] Early use of boot service memory
Message-ID: <20131115181641.GA2748@anatevka.fc.hp.com>
Reply-To: jerry.hoemann@hp.com
References: <20131113224503.GB25344@anatevka.fc.hp.com>
 <52840206.5020006@zytor.com>
 <20131113235708.GC25344@anatevka.fc.hp.com>
 <CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>
 <20131114180455.GA32212@anatevka.fc.hp.com>
 <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
 <20131115005049.GJ5116@anatevka.fc.hp.com>
 <20131115062417.GB9237@gmail.com>
 <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
 <5285C639.5040203@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5285C639.5040203@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 14, 2013 at 10:59:05PM -0800, H. Peter Anvin wrote:
> On 11/14/2013 10:55 PM, Yinghai Lu wrote:
> > 
> > Why just asking distros to append ",high" in their installation
> > program for 64bit by default?
> > 
> [...]
> > 
> > What is hpa's suggestion?
> > 
> 
> Pretty much what you just said ;)

The issue w/ efi_reserve_boot_services exists across several
versions and distros of linux.  So, I'd like to find a fix that
works across several kernel versions and distros.

the kernel and required utility code to allocate high isn't available
on distros based on pre 3.9 kernels.

While the alloc high code is a step in the right direction, it is
still green.  We are having much more problems getting crash dump
to work w/ top of tree kernels/utilities than we are having w/
distros running legacy bits.

Back porting this much larger change to multiple versions and
multiple distros isn't my first choice as its is much more work, much
more likely to destabilize distros w/ legacy kernels.

We will be passing along fixes for these other top of tree dump
issues as we find them,  but our first priority is enabling
our distro partners that happen to be using pre 3.9 based kernels.



Jerry


-- 

----------------------------------------------------------------------------
Jerry Hoemann            Software Engineer              Hewlett-Packard

3404 E Harmony Rd. MS 57                        phone:  (970) 898-1022
Ft. Collins, CO 80528                           FAX:    (970) 898-XXXX
                                                email:  jerry.hoemann@hp.com
----------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
