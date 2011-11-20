Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 90C0A6B0070
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 18:27:30 -0500 (EST)
Received: by iaek3 with SMTP id k3so8679811iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 15:27:28 -0800 (PST)
Date: Sun, 20 Nov 2011 15:27:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc 06/18] slub: Use page variable instead of c->page.
In-Reply-To: <20111111200729.024403984@linux.com>
Message-ID: <alpine.DEB.2.00.1111201527130.30815@chino.kir.corp.google.com>
References: <20111111200711.156817886@linux.com> <20111111200729.024403984@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, 11 Nov 2011, Christoph Lameter wrote:

> The kmem_cache_cpu object pointed to by c will become
> volatile with the lockless patches later so extract
> the c->page pointer at certain times.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
