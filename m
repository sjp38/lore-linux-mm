From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 0/3] Cpu alloc slub support V2: Replace percpu allocator in slub.c
Date: Fri, 03 Oct 2008 08:24:36 -0700
Message-ID: <20081003152436.089811999@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Slub also has its own per cpu allocator. Get rid of it and use cpu_alloc().

V1->V2
- Fix 2 bugs in patches (node[] array problem, inverted check)
- Change reservation of percpu area defaults.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
