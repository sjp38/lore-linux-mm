Date: Wed, 18 May 2005 08:20:23 -0700
From: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Message-Id: <200505181520.j4IFKNYi026893@snoqualmie.dp.intel.com>
Subject: [patch 0/4] x86-64 sparsemem support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de, akpm@osdl.org
Cc: apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are a set of patches against 2.6.12-rc4-mm2 that 
enable the use of the sparsemem implementation for x86-64
NUMA kernels.  I've boot tested these for the normal contiguous
configuration as well as NUMA configurations using both
discontigmem and sparsemem options.  The NUMA configurations
have been tested using the "numa=fake" option as I don't have
direct access to a true x86-64 NUMA machine.  

For reference, these have been in the memory hotplug tree
Dave has been maintaining and also form the basis for supporting
memory hotplug.  Please review and consider for inclusion in -mm
for wider testing.  Patches to follow...

matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
