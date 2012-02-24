Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id BE1F86B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 16:45:35 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3726547pbc.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 13:45:35 -0800 (PST)
Date: Fri, 24 Feb 2012 13:45:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120224151025.GA1848@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1202241342240.22880@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223150238.GA15427@dhcp231-144.rdu.redhat.com> <alpine.DEB.2.00.1202231505080.26362@chino.kir.corp.google.com>
 <20120224151025.GA1848@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Fri, 24 Feb 2012, Josef Bacik wrote:

> Um well yeah, I'm rewriting a chunk of btrfs which was rapantly leaking memory
> so the OOM just couldn't keep up with how much I was sucking down.  This is
> strictly a developer is doing something stupid and needs help pointing out what
> it is sort of moment, not a day to day OOM.
>  

If you're debugging new kernel code and you realize that excessive amount 
of memory is being consumed so that nothing can even fork, you may want to 
try cat /proc/slabinfo before you get into that condition the next time 
around, although I already suspect that you know the cache you're leaking.  
It doesn't mean we need to add hundreds of lines of code to the kernel.  
Try kmemleak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
