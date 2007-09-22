Date: Sat, 22 Sep 2007 10:47:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/5] oom: add header file to Kbuild as unifdef
In-Reply-To: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Preprocess include/linux/oom.h before exporting it to userspace.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -286,6 +286,7 @@ unifdef-y += nfs_idmap.h
 unifdef-y += n_r3964.h
 unifdef-y += nubus.h
 unifdef-y += nvram.h
+unifdef-y += oom.h
 unifdef-y += parport.h
 unifdef-y += patchkey.h
 unifdef-y += pci.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
