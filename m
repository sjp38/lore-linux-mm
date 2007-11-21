Message-Id: <20071121100201.156191000@sgi.com>
Date: Wed, 21 Nov 2007 02:02:01 -0800
From: travis@sgi.com
Subject: [PATCH 0/2] x86: Reduce pressure on stack from cpumask usage -v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: mingo@elte.hu, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

v2:
    - fix some compile errors when NR_CPUS > default for ia386 (128 & 4096)
    - remove unneccessary includes

Convert cpumask_of_cpu to use a static percpu data array and
set_cpus_allowed to pass the cpumask_t arg as a pointer.

Conditioned on NR_CPUS > BITS_PER_LONG.

Compiled and tested for i386 and x86_64.  I'd appreciate
feedback on other architectures.

(Note: there are still compile/test errors when NR_CPUS > 256
due to cpu id being 8 bits among other things.)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
