Date: Mon, 1 Dec 2008 12:09:33 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-Reply-To: <493420B2.8050907@gmail.com>
Message-ID: <Pine.LNX.4.64.0812011207400.16919@quilx.com>
References: <20081201083128.GB2529@wotan.suse.de>  <20081201120002.GB10790@wotan.suse.de>
 <4933E2C3.4020400@gmail.com>  <1228138641.14439.18.camel@penberg-laptop>
 <Pine.LNX.4.64.0812010828150.14977@quilx.com>  <4933F925.3020907@gmail.com>
 <20081201162018.GF10790@wotan.suse.de>  <49341915.5000900@gmail.com>
 <20081201171219.GI10790@wotan.suse.de>  <84144f020812010925r6c5f9c85p32f180c06085b496@mail.gmail.com>
 <84144f020812010932l540b26dr57716d8abea2562@mail.gmail.com> <493420B2.8050907@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Alexey Starikovskiy wrote:

> > Though I suspect this situation could be improved by avoiding those
> > fairly big unions ACPI does (like union acpi_operand_object).
> >
> No, last time I checked, operand may get down to 16 bytes in 32-bit case --
> save byte by having 3 types of operands... and making 2 more caches :)

SLAB has a minimum allocation size of 32 bytes so it would not make a
difference there.

SLUB can go down to 8 bytes which would enable you to save more. Adding
new caches most of the time simply lead to incrementing a counter in
a similar kmem_cache structure.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
