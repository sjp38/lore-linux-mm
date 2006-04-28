Date: Fri, 28 Apr 2006 06:57:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] page migration: Drop nr_refs parameter
In-Reply-To: <20060428163033.4fa4863a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604280656500.32052@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428060317.30257.27066.sendpatchset@schroedinger.engr.sgi.com>
 <20060428163033.4fa4863a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Apr 2006, KAMEZAWA Hiroyuki wrote:

> Then, could you add this comment to migrate_page_remove_references
> (renamed as migrate_page_move_mapping) ?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 23:39:11.853319378 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-28 06:56:36.856624280 -0700
@@ -248,6 +248,11 @@
 
 /*
  * Remove or replace the page in the mapping
+ *
+ * The number of remaining references must be:
+ * 1 for anonymous pages without a mapping
+ * 2 for pages with a mapping
+ * 3 for pages with a mapping and PagePrivate set.
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
