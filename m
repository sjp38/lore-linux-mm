Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
From: Andi Kleen <andi@firstfloor.org>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
Date: Sat, 19 Jan 2008 07:35:06 +0100
In-Reply-To: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> (Mel Gorman's message of "Fri\, 18 Jan 2008 15\:35\:29 +0000 \(GMT\)")
Message-ID: <p73hcha9vc5.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> writes:

> A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> at the restrictions on setting NUMA on x86 to see if they could be lifted.

The problem with i386 CONFIG_NUMA previously was not that it didn't
boot on normal non NUMA systems, but that it didn't boot on very
common NUMA systems: Opterons.  Have you tested if that is fixed now?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
