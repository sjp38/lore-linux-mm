Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 7D3E56B0044
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 18:25:24 -0400 (EDT)
Message-ID: <1333232714.30734.6.camel@pasglop>
Subject: Re: [PATCH 2/7] mm: introduce vma flag VM_ARCH_1
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 01 Apr 2012 08:25:14 +1000
In-Reply-To: <20120331092910.19920.29396.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
	 <20120331092910.19920.29396.stgit@zurg>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, 2012-03-31 at 13:29 +0400, Konstantin Khlebnikov wrote:
> This patch shuffles some bits in vma->vm_flags
> 
> before patch:
> 
>         0x00000200      0x01000000      0x20000000      0x40000000
> x86     VM_NOHUGEPAGE   VM_HUGEPAGE     -               VM_PAT
> powerpc -               -               VM_SAO          -
> parisc  VM_GROWSUP      -               -               -
> ia64    VM_GROWSUP      -               -               -
> nommu   -               VM_MAPPED_COPY  -               -
> others  -               -               -               -
> 
> after patch:
> 
>         0x00000200      0x01000000      0x20000000      0x40000000
> x86     -               VM_PAT          VM_HUGEPAGE     VM_NOHUGEPAGE
> powerpc -               VM_SAO          -               -
> parisc  -               VM_GROWSUP      -               -
> ia64    -               VM_GROWSUP      -               -
> nommu   -               VM_MAPPED_COPY  -               -
> others  -               VM_ARCH_1       -               -
> 
> And voila! One completely free bit.

Great :-) Let me know when you free VM_ARCH_2 as well as I have good use
for it too :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
