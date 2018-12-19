Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 06/12] __wr_after_init: Documentation: self-protection
Date: Wed, 19 Dec 2018 23:33:32 +0200
Message-Id: <20181219213338.26619-7-igor.stoppa@huawei.com>
In-Reply-To: <20181219213338.26619-1-igor.stoppa@huawei.com>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Update the self-protection documentation, to mention also the use of the
__wr_after_init attribute.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 Documentation/security/self-protection.rst | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/Documentation/security/self-protection.rst b/Documentation/security/self-protection.rst
index f584fb74b4ff..df2614bc25b9 100644
--- a/Documentation/security/self-protection.rst
+++ b/Documentation/security/self-protection.rst
@@ -84,12 +84,14 @@ For variables that are initialized once at ``__init`` time, these can
 be marked with the (new and under development) ``__ro_after_init``
 attribute.
 
-What remains are variables that are updated rarely (e.g. GDT). These
-will need another infrastructure (similar to the temporary exceptions
-made to kernel code mentioned above) that allow them to spend the rest
-of their lifetime read-only. (For example, when being updated, only the
-CPU thread performing the update would be given uninterruptible write
-access to the memory.)
+Others, which are statically allocated, but still need to be updated
+rarely, can be marked with the ``__wr_after_init`` attribute.
+
+The update mechanism must avoid exposing the data to rogue alterations
+during the update. For example, only the CPU thread performing the update
+would be given uninterruptible write access to the memory.
+
+Currently there is no protection available for data allocated dynamically.
 
 Segregation of kernel memory from userspace memory
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 
2.19.1
