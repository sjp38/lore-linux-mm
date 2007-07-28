Date: Sat, 28 Jul 2007 09:38:44 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mm] fix filemap.c kernel-doc
Message-Id: <20070728093844.943f57ca.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Fix kernel-doc warning:
Warning(linux-2.6.23-rc1-mm1//mm/filemap.c:864): No description found for parameter 'ra'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.23-rc1-mm1.orig/mm/filemap.c
+++ linux-2.6.23-rc1-mm1/mm/filemap.c
@@ -840,7 +840,7 @@ static void shrink_readahead_size_eio(st
 /**
  * do_generic_mapping_read - generic file read routine
  * @mapping:	address_space to be read
- * @_ra:	file's readahead state
+ * @ra:		file's readahead state
  * @filp:	the file to read
  * @ppos:	current file position
  * @desc:	read_descriptor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
