Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id A64376B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:59:21 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id x12so2027599qac.21
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:59:21 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id e9si6741465qac.94.2014.06.19.07.59.20
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 07:59:21 -0700 (PDT)
Date: Thu, 19 Jun 2014 09:59:18 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: percpu: micro-optimize round-to-even
In-Reply-To: <20140619143458.GF26904@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1406190957030.2785@gentwo.org>
References: <1403172149-25353-1-git-send-email-linux@rasmusvillemoes.dk> <20140619132536.GF11042@htj.dyndns.org> <alpine.DEB.2.11.1406190925430.2785@gentwo.org> <20140619143458.GF26904@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014, Tejun Heo wrote:

> Indeed, a patch?

Subject: percpu: Use ALIGN macro instead of hand coding alignment calculation

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/percpu.c
===================================================================
--- linux.orig/mm/percpu.c	2014-06-04 13:43:12.541466633 -0500
+++ linux/mm/percpu.c	2014-06-19 09:56:10.458023912 -0500
@@ -720,8 +720,7 @@ static void __percpu *pcpu_alloc(size_t
 	if (unlikely(align < 2))
 		align = 2;

-	if (unlikely(size & 1))
-		size++;
+	size = ALIGN(size, 2);

 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
