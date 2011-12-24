Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id AD7A96B005A
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 22:00:25 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 3/6] memcg: remove unused variable
Date: Sat, 24 Dec 2011 05:00:16 +0200
Message-Id: <1324695619-5537-3-git-send-email-kirill@shutemov.name>
In-Reply-To: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

mm/memcontrol.c: In function a??mc_handle_file_ptea??:
mm/memcontrol.c:5206:16: warning: variable a??inodea?? set but not used [-Wunused-but-set-variable]

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4bac3a2..627c19e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5203,7 +5203,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 			unsigned long addr, pte_t ptent, swp_entry_t *entry)
 {
 	struct page *page = NULL;
-	struct inode *inode;
 	struct address_space *mapping;
 	pgoff_t pgoff;
 
@@ -5212,7 +5211,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	if (!move_file())
 		return NULL;
 
-	inode = vma->vm_file->f_path.dentry->d_inode;
 	mapping = vma->vm_file->f_mapping;
 	if (pte_none(ptent))
 		pgoff = linear_page_index(vma, addr);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
