Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5BBBF6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:02:18 -0500 (EST)
Received: by pbaa12 with SMTP id a12so1812042pba.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 14:02:17 -0800 (PST)
Date: Wed, 1 Feb 2012 14:02:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup 4/9] slub: Simplify control flow in
 __slab_alloc()
In-Reply-To: <20120123201707.746733370@linux.com>
Message-ID: <alpine.DEB.2.00.1202011402040.10854@chino.kir.corp.google.com>
References: <20120123201646.924319545@linux.com> <20120123201707.746733370@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, 23 Jan 2012, Christoph Lameter wrote:

> Simplify control flow a bit avoiding nesting.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
