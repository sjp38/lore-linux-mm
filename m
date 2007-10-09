Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
In-Reply-To: <1191920123.9719.71.camel@caritas-dev.intel.com>
References: <1191912010.9719.18.camel@caritas-dev.intel.com> <200710090125.27263.nickpiggin@yahoo.com.au> <1191918139.9719.47.camel@caritas-dev.intel.com> <200710090206.22383.nickpiggin@yahoo.com.au> <1191920123.9719.71.camel@caritas-dev.intel.com>
Date: Tue, 9 Oct 2007 13:44:47 +0200
Message-Id: <E1IfDW3-0001qA-9c@flower>
From: Oleg Verych <olecom@flower.upol.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Tue, 09 Oct 2007 16:55:23 +0800
>
> On Tue, 2007-10-09 at 02:06 +1000, Nick Piggin wrote:
>> On Tuesday 09 October 2007 18:22, Huang, Ying wrote:
[]
>> I'm just wondering whether you really need to access highmem in
>> boot code...
>
> Because the zero page (boot_parameters) of i386 boot protocol has 4k
> limitation, a linked list style boot parameter passing mechanism (struct
> setup_data) is proposed by Peter Anvin. The linked list is provided by
> bootloader, so it is possible to be in highmem region.

Can it be explained, why boot protocol and boot line must be expanded?
This amount of code for what?

 arch/i386/Kconfig            |    3 -
 arch/i386/boot/header.S      |    8 +++
 arch/i386/kernel/setup.c     |   92 +++++++++++++++++++++++++++++++++++++++++++
 arch/x86_64/kernel/setup.c   |   37 +++++++++++++++++
 include/asm-i386/bootparam.h |   15 +++++++
 include/asm-i386/io.h        |    7 +++
 include/linux/mm.h           |    2
 mm/memory.c                  |   24 +++++++++++
 

If it is proposed for passing ACPI makeup language bugfixes by boot
line for ACPI parser in the kernel, or "telling to kernel what to do
via EFI" then it's kind of very nasty red flag.

I'd suggest to have initramfs image ready with all possible
data/options/actions based on very small amount of possible boot line
information.

Any _right_ use-cases explained for dummies are appreciated.

Thanks.
--
-o--=O`C
 #oo'L O
<___=E M

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
