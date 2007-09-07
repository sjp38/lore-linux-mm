Message-Id: <20070907040943.467530005@sgi.com>
Date: Thu, 06 Sep 2007 21:09:43 -0700
From: travis@sgi.com
Subject: [PATCH 0/3] core: fix build error when referencing arch specific structures
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Since the core kernel routines need to reference cpu_sibling_map,
whether it be a static array or a per_cpu data variable, an access
function has been defined.

In addition, changes have been made to the ia64 and ppc64 arch's to
move the cpu_sibling_map from a static cpumask_t array [NR_CPUS] to
be per_cpu cpumask_t arrays.

Note that I do not have the ability to build or test patch 3/3, the
ppc64 changes.

Patches are referenced against 2.6.23-rc4-mm1 .

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
