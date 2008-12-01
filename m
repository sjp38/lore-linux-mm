Received: by qyk5 with SMTP id 5so3339044qyk.14
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 09:32:57 -0800 (PST)
Message-ID: <84144f020812010932l540b26dr57716d8abea2562@mail.gmail.com>
Date: Mon, 1 Dec 2008 19:32:56 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-Reply-To: <84144f020812010925r6c5f9c85p32f180c06085b496@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081201083128.GB2529@wotan.suse.de>
	 <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com>
	 <1228138641.14439.18.camel@penberg-laptop>
	 <Pine.LNX.4.64.0812010828150.14977@quilx.com>
	 <4933F925.3020907@gmail.com> <20081201162018.GF10790@wotan.suse.de>
	 <49341915.5000900@gmail.com> <20081201171219.GI10790@wotan.suse.de>
	 <84144f020812010925r6c5f9c85p32f180c06085b496@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Alexey Starikovskiy <aystarik@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 1, 2008 at 7:25 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> Though I suspect using kmem caches to combat the internal
> fragmentation caused by kmalloc() rounding is not worth it in this
> case.

Btw, just for the record, the ACPI objects are indeed a bad fit for
kmalloc() as reported by SLUB statistics:

[ The size of ACPI kmem caches with wasted bytes per object in parenthesis. ]

                 32-bit size  64-bit size
  Acpi-Namespace  24 (8)       32 (0)
  Acpi-Operand    40 (24)      72 (24)
  Acpi-Parse      32 (0)       48 (16)
  Acpi-ParseExt   44 (20)      72 (24)
  Acpi-State      44 (20)      80 (16)

Though I suspect this situation could be improved by avoiding those
fairly big unions ACPI does (like union acpi_operand_object).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
