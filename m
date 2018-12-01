Return-Path: <linux-kernel-owner@vger.kernel.org>
From: YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] mm/hmm: remove set but not used variable 'devmem'
Date: Sat, 1 Dec 2018 02:06:11 +0000
Message-ID: <1543629971-128377-1-git-send-email-yuehaibing@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: linux-kernel-owner@vger.kernel.org
To: jglisse@redhat.com, akpm@linux-foundation.org, sfr@canb.auug.org.au, dan.j.williams@intel.com
Cc: YueHaibing <yuehaibing@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fixes gcc '-Wunused-but-set-variable' warning:

mm/hmm.c: In function 'hmm_devmem_ref_kill':
mm/hmm.c:995:21: warning:
 variable 'devmem' set but not used [-Wunused-but-set-variable]

It not used any more since commit 35d39f953d4e ("mm, hmm: replace
hmm_devmem_pages_create() with devm_memremap_pages()")

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/hmm.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 50fbaf8..361f370 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -992,9 +992,6 @@ static void hmm_devmem_ref_exit(void *data)
 
 static void hmm_devmem_ref_kill(struct percpu_ref *ref)
 {
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(ref, struct hmm_devmem, ref);
 	percpu_ref_kill(ref);
 }
