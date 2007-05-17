From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH] MM: use DIV_ROUND_UP() in mm/memory.c
Date: Thu, 17 May 2007 23:05:10 +0200
References: <200704241610.23342.eike-kernel@sf-tec.de> <20070503202808.4f835c8a.akpm@linux-foundation.org>
In-Reply-To: <20070503202808.4f835c8a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705172305.11267.eike-kernel@sf-tec.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Replace a hand coded version of DIV_ROUND_UP().

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de

---
commit ab35916f807eb4f2019a208e96cb0bddbb91dfc3
tree 6dc4485902c1a96a09ed287270de108630b26719
parent 335aa0289219ca2c1dc309d6bf856d4b25ad8746
author Rolf Eike Beer <eike-kernel@sf-tec.de> Thu, 17 May 2007 23:03:06 +0200
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Thu, 17 May 2007 23:03:06 +0200

 mm/memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index cb94488..5bc26b7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2674,7 +2674,7 @@ int make_pages_present(unsigned long addr, unsigned long end)
 	write = (vma->vm_flags & VM_WRITE) != 0;
 	BUG_ON(addr >= end);
 	BUG_ON(end > vma->vm_end);
-	len = (end+PAGE_SIZE-1)/PAGE_SIZE-addr/PAGE_SIZE;
+	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
 	ret = get_user_pages(current, current->mm, addr,
 			len, write, 0, NULL, NULL);
 	if (ret < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
