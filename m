Received: by qw-out-1920.google.com with SMTP id 9so578210qwj.44
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 09:25:08 -0800 (PST)
Message-ID: <84144f020812010925r6c5f9c85p32f180c06085b496@mail.gmail.com>
Date: Mon, 1 Dec 2008 19:25:08 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-Reply-To: <20081201171219.GI10790@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081201083128.GB2529@wotan.suse.de>
	 <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
	 <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com>
	 <1228138641.14439.18.camel@penberg-laptop>
	 <Pine.LNX.4.64.0812010828150.14977@quilx.com>
	 <4933F925.3020907@gmail.com> <20081201162018.GF10790@wotan.suse.de>
	 <49341915.5000900@gmail.com> <20081201171219.GI10790@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Alexey Starikovskiy <aystarik@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 08:04:21PM +0300, Alexey Starikovskiy wrote:
>> Nick Piggin wrote:
>> >Hmm.
>> >Acpi-Operand        2641   2773     64   59    1 : tunables  120   60    8
>> >: slabdata     47     47     0
>> >Acpi-ParseExt          0      0     64   59    1 : tunables  120   60    8
>> >: slabdata      0      0     0
>> >Acpi-Parse             0      0     40   92    1 : tunables  120   60    8
>> >: slabdata      0      0     0
>> >Acpi-State             0      0     80   48    1 : tunables  120   60    8
>> >: slabdata      0      0     0
>> >Acpi-Namespace      1711   1792     32  112    1 : tunables  120   60    8
>> >: slabdata     16     16     0
>> >
>> >
>> >Looks different for my thinkpad.
>> >
>> Probably this is SLUB vs. SLAB thing Pecca was talking about...

On Mon, Dec 1, 2008 at 7:12 PM, Nick Piggin <npiggin@suse.de> wrote:
> Sizes should not be bigger with SLUB. Although if you have SLUB debugging
> turned on then maybe the size gets padded with redzones, but in that
> configuration you don't expect memory saving anyway because padding bloats
> things up.

Please keep in mind that SLUB slab merging kicks in and at least on
32-bit merges some of the caches with dentry caches and so forth. So
with SLUB, separate caches are probably OK. Unfortunately I don't have
any machines running with SLAB currently so I don't have any numbers.
But again, for SLAB, if there's not enough activity going on, you end
up with partially filled slabs which wastes memory.

Though I suspect using kmem caches to combat the internal
fragmentation caused by kmalloc() rounding is not worth it in this
case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
