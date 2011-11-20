Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C38E6B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 18:11:00 -0500 (EST)
Received: by iaek3 with SMTP id k3so8662595iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 15:10:58 -0800 (PST)
Date: Sun, 20 Nov 2011 15:10:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc 02/18] slub: Separate out kmem_cache_cpu processing from
 deactivate_slab
In-Reply-To: <20111111200726.286206880@linux.com>
Message-ID: <alpine.DEB.2.00.1111201508230.30815@chino.kir.corp.google.com>
References: <20111111200711.156817886@linux.com> <20111111200726.286206880@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, 11 Nov 2011, Christoph Lameter wrote:

> Processing on fields of kmem_cache needs to be outside of deactivate_slab()
> since we will be handling that with cmpxchg_double later.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
