Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 0/3] NUMA boot hash allocation interleaving
Date: Wed, 15 Dec 2004 09:25:55 -0800
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F02900608@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Andi Kleen <ak@suse.de>, Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> Also at least on IA64 the large page size is usually 1-2GB 
>> and that would seem to be a little too large to me for
>> interleaving purposes. Also it may prevent the purpose 
>> you implemented it - not using too much memory from a single
>> node. 
>
>Yes, that'd bork it. But I thought that they had a large sheaf of
>mapping sizes to chose from on ia64?

Yes, ia64 supports lots of pagesizes (the exact list for each cpu
model can be found in /proc/pal/cpu*/vm_info, but the architecture
requires that 4k, 8k, 16k, 64k, 256k, 1m, 4m, 16m, 64m, 256m be
supported by all implementations).  To make good use of them
for vmalloc() would require that we switch the kernel over to
using long format VHPT ... as well as all the architecture
independent changes that Andi listed.

It would be interesting to see some perfmon data on TLB miss rates
before and after this patch, but I'd personally be amazed if you
could find a macro-level benchmark that could reliably detect the
perfomance effects relating to TLB caused by this change.

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
