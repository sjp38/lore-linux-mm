Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2408D6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 19:21:14 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i64so1736455wmd.8
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 16:21:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l46sor3835240wrl.38.2018.03.02.16.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 16:21:12 -0800 (PST)
Subject: Re: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot
 on Zotac CI-321
References: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
 <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
From: Heiner Kallweit <hkallweit1@gmail.com>
Message-ID: <8c6c0f9d-0f47-2fc9-5cb5-6335ef1152cd@gmail.com>
Date: Sat, 3 Mar 2018 01:21:07 +0100
MIME-Version: 1.0
In-Reply-To: <CAA42JLZRxCGSsW5FKpH3AjZGbaUyrcRPdVBtMQcc4ZcxKNuDQw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan-Linux Cui <dexuan.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dexuan Cui <decui@microsoft.com>

Am 03.03.2018 um 00:50 schrieb Dexuan-Linux Cui:
> On Fri, Mar 2, 2018 at 12:57 PM, Heiner Kallweit <hkallweit1@gmail.com <mailto:hkallweit1@gmail.com>> wrote:
> 
>     Recently my Mini PC Zotac CI-321 started to reboot immediately before
>     anything was written to the console.
> 
>     Bisecting lead to b91993a87aff "x86/boot/compressed/64: Prepare
>     trampoline memory" being the change breaking boot.
> 
>     If you need any more information, please let me know.
> 
>     Rgds, Heiner
> 
> 
> This may fix the issue: https://lkml.org/lkml/2018/2/13/668
> 
> Kirill posted a v2 patchset 3 days ago and I suppose the patchset should include the fix.
> 
Thanks for the link. I bisected based on the latest next kernel including
v2 of the patchset (IOW - the potential fix is included already).

So it seems that the proposed fix fixes certain scenarios but not all.

> -- Dexuan

Using the content of arch/x86/boot/compressed from Feb 9th the system boots
and dmesg looks like this (HTH). CPU is a Celeron 2961Y, distro is Arch Linux.


[Mar 3 01:04] microcode: microcode updated early to revision 0x21, date = 2017-11-20
[  +0.000000] Linux version 4.16.0-rc3-next-20180302+ (root@zotac) (gcc version 7.3.0 (GCC)) #3 SMP Sat Mar 3 00:53:52 CET 2018
[  +0.000000] Command line: root=/dev/sda2 rw initrd=/intel-ucode.img initrd=/initramfs-linux.img
[  +0.000000] Intel Spectre v2 broken microcode detected; disabling Speculation Control
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[  +0.000000] x86/fpu: Enabled xstate features 0x3, context size is 576 bytes, using 'standard' format.
[  +0.000000] e820: BIOS-provided physical RAM map:
[  +0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000057fff] usable
[  +0.000000] BIOS-e820: [mem 0x0000000000058000-0x0000000000058fff] reserved
[  +0.000000] BIOS-e820: [mem 0x0000000000059000-0x000000000009dfff] usable
[  +0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reserved
[  +0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cb2ddfff] usable
[  +0.000000] BIOS-e820: [mem 0x00000000cb2de000-0x00000000cb2e4fff] ACPI NVS
[  +0.000000] BIOS-e820: [mem 0x00000000cb2e5000-0x00000000cba53fff] usable
[  +0.000000] BIOS-e820: [mem 0x00000000cba54000-0x00000000cbcfefff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000cbcff000-0x00000000db778fff] usable
[  +0.000000] BIOS-e820: [mem 0x00000000db779000-0x00000000db82efff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000db82f000-0x00000000db87dfff] usable
[  +0.000000] BIOS-e820: [mem 0x00000000db87e000-0x00000000db9acfff] ACPI NVS
[  +0.000000] BIOS-e820: [mem 0x00000000db9ad000-0x00000000dbffefff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000dbfff000-0x00000000dbffffff] usable
[  +0.000000] BIOS-e820: [mem 0x00000000dd000000-0x00000000df1fffff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[  +0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[  +0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000011fdfffff] usable
[  +0.000000] NX (Execute Disable) protection: active
[  +0.000000] efi: EFI v2.31 by American Megatrends
[  +0.000000] efi:  ESRT=0xdbf84998  ACPI=0xdb980000  ACPI 2.0=0xdb980000  SMBIOS=0xdbf84598
[  +0.000000] secureboot: Secure boot disabled
[  +0.000000] random: fast init done
[  +0.000000] SMBIOS 2.8 present.
[  +0.000000] DMI: ZOTAC ZBOX-CI321NANO/ZBOX-CI321NANO, BIOS B246P105 06/01/2015

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
