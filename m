Subject: [PATCH 5/5] mm/... convert #include "linux/..." to #include
	<linux/...>
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Sun, 19 Aug 2007 15:19:43 -0700
Message-Id: <1187561983.4200.145.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <clameter@sgi.com>, Eric Dumazet <dada1@cosmosbay.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(untested)

There are several files that 
#include "linux/file" not #include <linux/file>
#include "asm/file" not #include <asm/file>

Here's a little script that converts them:

egrep -i -r -l --include=*.[ch] \
"^[[:space:]]*\#[[:space:]]*include[[:space:]]*\"(linux|asm)/(.*)\"" * \
| xargs sed -i -e 's/^[[:space:]]*#[[:space:]]*include[[:space:]]*"\(linux\|asm\)\/\(.*\)"/#include <\1\/\2>/g'

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/mm/slab.c b/mm/slab.c
index a684778..976aeff 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -334,7 +334,7 @@ static __always_inline int index_of(const size_t size)
 		return i; \
 	else \
 		i++;
-#include "linux/kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		__bad_size();
 	} else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
