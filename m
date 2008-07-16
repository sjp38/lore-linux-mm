Message-ID: <487E1ACF.3030603@linux-foundation.org>
Date: Wed, 16 Jul 2008 10:59:11 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>
In-Reply-To: <1216211371.3122.46.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Patch to do this the right way in slub:

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-07-16 10:42:07.000000000 -0500
+++ linux-2.6/mm/slub.c	2008-07-16 10:53:36.000000000 -0500
@@ -1860,6 +1860,10 @@
 
 		rem = slab_size % size;
 
+		/* Never waste more than half of the size of an object*/
+		if (rem > size / 2)
+			continue;
+
 		if (rem <= slab_size / fract_leftover)
 			break;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
