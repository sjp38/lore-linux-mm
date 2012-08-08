Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D35976B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 09:15:12 -0400 (EDT)
Message-ID: <50226659.8080608@parallels.com>
Date: Wed, 8 Aug 2012 17:15:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common10 [14/20] Shrink __kmem_cache_create() parameter lists
References: <20120803192052.448575403@linux.com> <20120803192156.005879886@linux.com>
In-Reply-To: <20120803192156.005879886@linux.com>
Content-Type: multipart/mixed;
	boundary="------------090802000608080401030002"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

--------------090802000608080401030002
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/03/2012 11:21 PM, Christoph Lameter wrote:
> Do the initial settings of the fields in common code. This will allow
> us to push more processing into common code later and improve readability.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Doesn't compile.

Log attached

--------------090802000608080401030002
Content-Type: text/plain; charset="UTF-8"; name="log"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="log"

make[1]: Nothing to be done for `all'.
make[1]: Nothing to be done for `relocs'.
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC      mm/slub.o
mm/slub.c: In function a??create_kmalloc_cachea??:
mm/slub.c:3231:9: warning: passing argument 2 of a??kmem_cache_opena?? makes integer from pointer without a cast [enabled by default]
mm/slub.c:3001:12: note: expected a??long unsigned inta?? but argument is of type a??const char *a??
mm/slub.c:3231:9: error: too many arguments to function a??kmem_cache_opena??
mm/slub.c:3001:12: note: declared here
mm/slub.c: In function a??kmem_cache_inita??:
mm/slub.c:3686:3: warning: passing argument 2 of a??kmem_cache_opena?? makes integer from pointer without a cast [enabled by default]
mm/slub.c:3001:12: note: expected a??long unsigned inta?? but argument is of type a??char *a??
mm/slub.c:3686:3: error: too many arguments to function a??kmem_cache_opena??
mm/slub.c:3001:12: note: declared here
mm/slub.c:3695:3: warning: passing argument 2 of a??kmem_cache_opena?? makes integer from pointer without a cast [enabled by default]
mm/slub.c:3001:12: note: expected a??long unsigned inta?? but argument is of type a??char *a??
mm/slub.c:3695:3: error: too many arguments to function a??kmem_cache_opena??
mm/slub.c:3001:12: note: declared here
make[1]: *** [mm/slub.o] Error 1
make: *** [mm] Error 2

--------------090802000608080401030002--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
