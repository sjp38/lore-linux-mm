Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id BDF046B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 03:02:26 -0400 (EDT)
Received: by oihr66 with SMTP id r66so103313541oih.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 00:02:26 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id y186si865687oif.37.2015.07.08.00.02.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 00:02:26 -0700 (PDT)
Received: by obdbs4 with SMTP id bs4so144726502obd.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 00:02:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150708064607.GB7079@osiris>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<1436288623-13007-3-git-send-email-emunson@akamai.com>
	<20150708064607.GB7079@osiris>
Date: Wed, 8 Jul 2015 09:02:25 +0200
Message-ID: <CAMuHMdUS72nYDo=chtcZMv-ZNVU0RhxvVLvMYvSFLtRk_wXrgw@mail.gmail.com>
Subject: Re: [PATCH V3 2/5] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, alpha <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-buildroot-devel@lists.sourceforge.net>, Cris <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, "moderated list:PANASONIC MN10300..." <linux-am33-list@redhat.com>, Parisc List <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jul 8, 2015 at 8:46 AM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
>> diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
>> index 1acad02..f6d81d6 100644
>> --- a/arch/s390/kernel/syscalls.S
>> +++ b/arch/s390/kernel/syscalls.S
>> @@ -363,3 +363,6 @@ SYSCALL(sys_bpf,compat_sys_bpf)
>>  SYSCALL(sys_s390_pci_mmio_write,compat_sys_s390_pci_mmio_write)
>>  SYSCALL(sys_s390_pci_mmio_read,compat_sys_s390_pci_mmio_read)
>>  SYSCALL(sys_execveat,compat_sys_execveat)
>> +SYSCALL(sys_mlock2,compat_sys_mlock2)                        /* 355 */
>> +SYSCALL(sys_munlock2,compat_sys_munlock2)
>> +SYSCALL(sys_munlockall2,compat_sys_munlockall2)
>
> FWIW, you would also need to add matching lines to the two files
>
> arch/s390/include/uapi/asm/unistd.h
> arch/s390/kernel/compat_wrapper.c
>
> so that the system call would be wired up on s390.

Similar comment for m68k:

arch/m68k/include/asm/unistd.h
arch/m68k/include/uapi/asm/unistd.h

I think you best look at the last commits that added system calls, for all
architectures, to make sure you don't do partial updates.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
