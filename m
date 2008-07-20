Received: by fg-out-1718.google.com with SMTP id 19so3276759fgg.4
        for <linux-mm@kvack.org>; Sun, 20 Jul 2008 08:15:29 -0700 (PDT)
Message-ID: <6101e8c40807200815x68da6731t210b8fbbbe510673@mail.gmail.com>
Date: Sun, 20 Jul 2008 17:15:29 +0200
From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: [RFC] x86 fix for stable
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: stable@kernel.org
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

git id: e22146e610bb7aed63282148740ab1d1b91e1d90

commit e22146e610bb7aed63282148740ab1d1b91e1d90
Author: Jack Steiner <steiner@sgi.com>
Date:   Wed Jul 16 11:11:59 2008 -0500

    x86: fix kernel_physical_mapping_init() for large x86 systems

    Fix bug in kernel_physical_mapping_init() that causes kernel
    page table to be built incorrectly for systems with greater
    than 512GB of memory.

    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Cc: linux-mm@kvack.org
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 27de243..306049e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -644,7 +644,7 @@ static unsigned long __init
kernel_physical_mapping_init(unsigned long start,
 		unsigned long pud_phys;
 		pud_t *pud;

-		next = start + PGDIR_SIZE;
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
 		if (next > end)
 			next = end;



-- 
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
