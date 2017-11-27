From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 2/5] x86/mm/kaiser: Add a banner
Date: Mon, 27 Nov 2017 23:31:12 +0100
Message-ID: <20171127223405.231444600@infradead.org>
References: <20171127223110.479550152@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=peterz-kaiser-banner.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at
List-Id: linux-mm.kvack.org

So we can more easily see if the shiny got enabled.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/mm/kaiser.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -425,6 +425,8 @@ void __init kaiser_init(void)
 	if (!kaiser_enabled)
 		return;
 
+	printk("All your KAISER are belong to us\n");
+
 	kaiser_init_all_pgds();
 
 	for_each_possible_cpu(cpu) {
