From: "Moore, Robert" <robert.moore@intel.com>
Date: Mon, 1 Dec 2008 09:20:03 -0800
Subject: RE: [patch][rfc] acpi: do not use kmem caches
Message-ID: <4911F71203A09E4D9981D27F9D8308580DC5D17C@orsmsx503.amr.corp.intel.com>
References: <20081201083128.GB2529@wotan.suse.de>
 <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
 <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com>
 <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com>
 <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com>
In-Reply-To: <4934149A.4020604@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>, Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "lenb@kernel.org" <lenb@kernel.org>
List-ID: <linux-mm.kvack.org>

As I recall, the ACPICA local cache greatly improves performance of the iASL compiler and AcpiExec on Windows (for BIOS writers, iASL on Windows is most important).


>-----Original Message-----
>From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-
>owner@vger.kernel.org] On Behalf Of Alexey Starikovskiy
>Sent: Monday, December 01, 2008 8:45 AM
>To: Nick Piggin
>Cc: Pekka Enberg; Linux Memory Management List; linux-acpi@vger.kernel.org;
>lenb@kernel.org
>Subject: Re: [patch][rfc] acpi: do not use kmem caches
>
>Nick Piggin wrote:
>> On Mon, Dec 01, 2008 at 05:02:50PM +0300, Alexey Starikovskiy wrote:
>>
>>> Because SLAB has standard memory wells of 2^x size. None of cached ACPI
>>> objects has exactly this size, so bigger block will be used. Plus,
>>> internal ACPICA caching will add some overhead.
>>>
>>
>> That's an insane looking caching thing now that I come to closely read
>> the code. There is so much stuff there that I thought it must have been
>> doing something useful which is why I didn't replace the Linux functions
>> with kmalloc/kfree directly.
>>
>> There is really some operating system you support that has such a poor
>> allocator that you think ACPI can do better in 300 lines of code? Why
>> not just rip that whole thing out?
>>
>You would laugh, this is due to Windows userspace debug library -- it
>checks for
>memory leaks by default, and it takes ages to do this.
>And ACPICA maintainer is sitting on Windows, so he _cares_.
>>> Do you have another interpreter in kernel space?
>>>
>>
>> So what makes it special?
>>
>>
>You don't know what size of program you will end up with.
>DSDT could be almost empty, or you could have several thousand of SSDT
>tables.
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
