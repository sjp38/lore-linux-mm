Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77FEE6B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:41:11 -0400 (EDT)
Date: Thu, 12 May 2011 11:41:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Slub cleanup6 2/5] slub: get_map() function to establish map
 of free objects in a slab
In-Reply-To: <alpine.DEB.2.00.1105111302020.9346@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1105121140510.27324@router.home>
References: <20110415194811.810587216@linux.com> <20110415194830.839125394@linux.com> <alpine.DEB.2.00.1105111302020.9346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="531368966-2111188955-1305144189=:9346"
Content-ID: <alpine.DEB.2.00.1105111303190.9346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-2111188955-1305144189=:9346
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <alpine.DEB.2.00.1105111303191.9346@chino.kir.corp.google.com>

On Wed, 11 May 2011, David Rientjes wrote:

> This generates a warning without CONFIG_SLUB_DEBUG:
>
> mm/slub.c:335: warning: =E2=80=98get_map=E2=80=99 defined but not used

Subject: slub: Avoid warning for !CONFIG_SLUB_DEBUG

Move the #ifdef so that get_map is only defined if CONFIG_SLUB_DEBUG is def=
ined.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/slub.c=092011-05-12 11:38:42.000000000 -0500
+++ linux-2.6/mm/slub.c=092011-05-12 11:39:40.000000000 -0500
@@ -326,6 +326,7 @@ static inline int oo_objects(struct kmem
 =09return x.x & OO_MASK;
 }

+#ifdef CONFIG_SLUB_DEBUG
 /*
  * Determine a map of object in use on a page.
  *
@@ -341,7 +342,6 @@ static void get_map(struct kmem_cache *s
 =09=09set_bit(slab_index(p, s, addr), map);
 }

-#ifdef CONFIG_SLUB_DEBUG
 /*
  * Debug settings:
  */
--531368966-2111188955-1305144189=:9346--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
