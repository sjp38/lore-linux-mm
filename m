Subject: [PATCH] Add maintainer for memory management
From: Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain
Date: Mon, 24 Jul 2006 00:01:47 -0400
Message-Id: <1153713707.4002.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I recently realized that there's no listing of a memory management
maintainer in the MAINTAINERS file. And didn't know about
linux-mm@kvack.org before Ingo enlightened me.  So I've decided to add
one.  Since Christoph is the first person to come in my mind as the
proper maintainer, (and I haven't asked him if he wants this title :)
I'll let him either add others to the list, or replace his name
altogether.

(I also used the email that he had in slab.c)

Note: If someone else is more likely the person than Christoph, don't be
offended that I didn't choose you.  It's just that Christoph has
responded the most whenever I mention anything about memory. So I chose
that as my criteria, than looking at who submits the most memory
patches.

-- Steve

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Index: linux-2.6.18-rc2/MAINTAINERS
===================================================================
--- linux-2.6.18-rc2.orig/MAINTAINERS	2006-07-23 23:32:13.000000000 -0400
+++ linux-2.6.18-rc2/MAINTAINERS	2006-07-23 23:34:10.000000000 -0400
@@ -1884,6 +1884,12 @@ S:     linux-scsi@vger.kernel.org
 W:     http://megaraid.lsilogic.com
 S:     Maintained
 
+MEMORY MANAGEMENT
+P:	Christoph Lameter
+M:	christoph@lameter.com
+L:	linux-mm@kvack.org
+S:	Maintained
+
 MEMORY TECHNOLOGY DEVICES (MTD)
 P:	David Woodhouse
 M:	dwmw2@infradead.org


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
