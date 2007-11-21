Date: Wed, 21 Nov 2007 12:12:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
In-Reply-To: <1195507183.27759.150.camel@localhost>
Message-ID: <Pine.LNX.4.64.0711211211390.2971@schroedinger.engr.sgi.com>
References: <20071113194025.150641834@polymtl.ca>  <1195160783.7078.203.camel@localhost>
 <20071115215142.GA7825@Krystal>  <1195164977.27759.10.camel@localhost>
 <20071116144742.GA17255@Krystal>  <1195495626.27759.119.camel@localhost>
 <20071119185258.GA998@Krystal>  <1195501381.27759.127.camel@localhost>
 <20071119195257.GA3440@Krystal>  <1195502983.27759.134.camel@localhost>
 <20071119202023.GA5086@Krystal>  <20071119130801.bd7b7021.akpm@linux-foundation.org>
 <1195507183.27759.150.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Nov 2007, Dave Hansen wrote:

> Which comes from:
>         
>         config OUT_OF_LINE_PFN_TO_PAGE
>                 def_bool X86_64
>                 depends on DISCONTIGMEM
>         
> and only on x86_64.  Perhaps it can go away with the
> discontig->sparsemem-vmemmap conversion.

The discontig/flatmem removal patch for x86_64 in mm already removes this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
