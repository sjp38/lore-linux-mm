Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 167F66B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:55:34 -0500 (EST)
Date: Tue, 29 Nov 2011 08:55:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: possible slab deadlock while doing ifenslave
In-Reply-To: <1322515158.2921.179.camel@twins>
Message-ID: <alpine.DEB.2.00.1111290854250.14101@router.home>
References: <201110121019.53100.hans@schillstrom.com>  <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>  <201110131019.58397.hans@schillstrom.com>  <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
 <1322515158.2921.179.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Hans Schillstrom <hans@schillstrom.com>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Mon, 28 Nov 2011, Peter Zijlstra wrote:

> Commit 30765b92 ("slab, lockdep: Annotate the locks before using
> them") moves the init_lock_keys() call from after g_cpucache_up =
> FULL, to before it. And overlooks the fact that init_node_lock_keys()
> tests for it and ignores everything !FULL.
>
> Introduce a LATE stage and change the lockdep test to be <LATE.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
