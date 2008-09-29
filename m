From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 0/4] Cpu alloc V6: Replace percpu allocator in modules.c
Date: Mon, 29 Sep 2008 12:35:00 -0700
Message-ID: <20080929193500.470295078@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Just do the bare mininum to establish a per cpu allocator. Later patchsets
will gradually build out the functionality.

The most critical issue that came up awhile back was how to configure
the size of the percpu area. Here we simply use a kernel parameter and use
the static size of the existing percpu allocator for modules as a default.

The effect of this patchset is to make the size of percpu data for modules
configurable. Its no longer fixed at 8000 bytes.

Changes:
V5->V6:
- Fix various issues in the per cpu alloc
- Make percpu reserve not depend on CONFIG_MODULES.

V4->V5:
- Fix various things pointed out by Pekka.
- Remove page alignment check from module.c and put it into cpu_alloc.c

V3->V4:
- Gut patches to the bare essentials: Only replace modules.c percpu alloocator
- Make percpu reserve area configurable via a kernel parameter


-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
