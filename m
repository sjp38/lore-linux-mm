Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 139FF6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:58:47 -0500 (EST)
Date: Tue, 29 Nov 2011 08:58:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: possible slab deadlock while doing ifenslave
In-Reply-To: <1322515222.2921.180.camel@twins>
Message-ID: <alpine.DEB.2.00.1111290855570.14101@router.home>
References: <201110121019.53100.hans@schillstrom.com>  <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>  <201110131019.58397.hans@schillstrom.com>  <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>  <1322515158.2921.179.camel@twins>
 <1322515222.2921.180.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Hans Schillstrom <hans@schillstrom.com>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Mon, 28 Nov 2011, Peter Zijlstra wrote:

> Currently we only annotate the kmalloc caches, annotate all of them.

What is the benefit? The metadata for off slab caches uses the
kmalloc array. Should the annotation for the kmalloc cache not be
sufficient by putting that into a different lock category? Non-kmalloc
caches already have a different lock category before this patch right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
