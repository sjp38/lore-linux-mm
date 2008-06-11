Date: Wed, 11 Jun 2008 17:01:21 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
Message-ID: <20080611170121.488ea001@bree.surriel.com>
In-Reply-To: <20080611135207.32a46267.akpm@linux-foundation.org>
References: <20080611180228.12987026@kernel>
	<20080611180230.7459973B@kernel>
	<20080611123724.3a79ea61.akpm@linux-foundation.org>
	<1213213980.20045.116.camel@calx>
	<20080611131108.61389481.akpm@linux-foundation.org>
	<1213216462.20475.36.camel@nimitz>
	<20080611135207.32a46267.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 13:52:07 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> access_process_vm-device-memory-infrastructure.patch is a powerpc
> feature, and it uses pmd_huge().
> 
> Am I missing something, or is pmd_huge() a whopping big grenade for x86
> developers to toss at non-x86 architectures?  It seems quite dangerous.

That function is used on x86 too, to access device memory that's
been mapped through /dev/memory or PCI thingies under /sys.

The X.org people need that patch on x86 to figure out what's in
the GPU's queue before it threw a fit; in short, to better debug
the X server.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
