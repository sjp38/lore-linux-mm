Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 53F566B0062
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 15:20:07 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so16448630qgd.18
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:20:07 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id j88si4976600qga.36.2014.06.04.12.20.06
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 12:20:06 -0700 (PDT)
Date: Wed, 4 Jun 2014 14:20:03 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: [PATCH] SLAB Maintainer update
Message-ID: <alpine.DEB.2.10.1406041417290.14004@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

As discussed in various threads on the side:


Remove one inactive maintainer, add two new ones and update
my email address. Plus add Andrew. And fix the glob to include
files like mm/slab_common.c

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/MAINTAINERS
===================================================================
--- linux.orig/MAINTAINERS	2014-06-04 14:13:49.404373350 -0500
+++ linux/MAINTAINERS	2014-06-04 14:16:51.804786701 -0500
@@ -8104,13 +8104,15 @@
 F:	drivers/usb/misc/sisusbvga/

 SLAB ALLOCATOR
-M:	Christoph Lameter <cl@linux-foundation.org>
+M:	Christoph Lameter <cl@linux.com>
 M:	Pekka Enberg <penberg@kernel.org>
-M:	Matt Mackall <mpm@selenic.com>
+M:	David Rientjes <rientjes@google.com>
+M:	Joonsoo Kim <iamjoonsoo.kim@lge.com>
+M:	Andrew Morton <akpm@linux-foundation.org>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	include/linux/sl?b*.h
-F:	mm/sl?b.c
+F:	mm/sl?b*

 SLEEPABLE READ-COPY UPDATE (SRCU)
 M:	Lai Jiangshan <laijs@cn.fujitsu.com>
Index: linux/CREDITS
===================================================================
--- linux.orig/CREDITS	2014-06-04 14:13:49.404373350 -0500
+++ linux/CREDITS	2014-06-04 14:13:49.400373430 -0500
@@ -9,6 +9,10 @@
 			Linus
 ----------

+M: Matt Mackal
+E: mpm@selenic.com
+D: SLOB slab allocator
+
 N: Matti Aarnio
 E: mea@nic.funet.fi
 D: Alpha systems hacking, IPv6 and other network related stuff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
