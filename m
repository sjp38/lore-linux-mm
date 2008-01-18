From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Date: Fri, 18 Jan 2008 15:35:29 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
at the restrictions on setting NUMA on x86 to see if they could be lifted.

The following two patches remove the restrictions on pagetable layout and
architecture type when setting NUMA on x86. This is aimed at improving
the testing coverage of NUMA code paths by allowing it to be set in more
situations. The dependency on CONFIG_ACPI is left due to possible SRAT
parsing (although this could also be lifted) and on EXPERIMENTAL as the
testing coverage for NUMA on x86 is so weak. The one potential gotcha is
that a definition of NR_NODE_MEMBLKS is moved to an arch-specific file. From
what I can see, this value was expected to be defined on a per-arch basis
and the definition in include/linux/acpi.h was an anomaly.

The patches in combination with the boot-numa-x86 fix have been boot-tested
on a bog-standard laptop with 512MB RAM, QEMU-i386 with 1324MB in a variety
of different configuarations and a NUMA-Q with its standard .config.

[1] For others watching, this fix was considered controversial as a
    potentially better solution existed as discussed in
    http://lkml.org/lkml/2007/8/24/220. However, this better alternative was
    never investigated properly and booting NUMA remained broken. The merged
    fix is a variation and while it does waste memory, it is considered better
    than crashing. Wider testing coverage may help motivate fixing this paths.
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
