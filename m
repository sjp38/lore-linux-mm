Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE5D8E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 02:58:35 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so3362267edb.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:58:35 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id g15si3081343ejd.9.2019.01.24.23.58.34
        for <linux-mm@kvack.org>;
        Thu, 24 Jan 2019 23:58:34 -0800 (PST)
Date: Fri, 25 Jan 2019 08:58:33 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-ID: <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
References: <20190122154407.18417-1-osalvador@suse.de>
 <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Wed, Jan 23, 2019 at 11:33:56AM +0100, David Hildenbrand wrote:
> If you use {} for the else case, please also do so for the if case.

Diff on top:

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 25aee4f04a72..d5810e522b72 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1338,9 +1338,9 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 				struct page *head = compound_head(page);
 
 				if (hugepage_migration_supported(page_hstate(head)) &&
-				    page_huge_active(head))
+				    page_huge_active(head)) {
 					return pfn;
-				else {
+				} else {
 					unsigned long skip;
 
 					skip = (1 << compound_order(head)) - (page - head);

> Apart from that this looks good to me
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

Thanks David ;-)

-- 
Oscar Salvador
SUSE L3
