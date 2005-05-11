Message-Id: <200505111505.j4BF52g07882@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation  (against 2.6.12-rc4) to
Date: Wed, 11 May 2005 08:05:01 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <17026.6227.225173.588629@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>, Andrew Morton <akpm@osdl.org>
Cc: mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Wednesday, May 11, 2005 7:36 AM
> The patch adresses thes issues by introducing yet another cache
> descriptor cached_hole_size that contains the largest known hole
> size below the current free_area_cache.  If a new request comes
> in the size is compared against the cached_hole_size and if the
> request can be filled with a hole below free_area_cache the
> search is started from the base instead.
> 
> arch/ia64/kernel/sys_ia64.c     |   15 ++++++++++++---
> arch/ppc64/mm/hugetlbpage.c     |   34 +++++++++++++++++++++++++++++-----
> arch/sparc64/kernel/sys_sparc.c |    8 ++++++++


To me, the original issue is a specific problem with 32-bit address space
fragmentation.  On first glance of the patch, the changes for 64-bit arches
are questionable here.  I will work on this.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
