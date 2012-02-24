Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2BF4A6B00E8
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 05:03:52 -0500 (EST)
Received: by dadv6 with SMTP id v6so2786211dad.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 02:03:51 -0800 (PST)
Date: Fri, 24 Feb 2012 02:03:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <alpine.LFD.2.02.1202240856370.1917@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1202240200380.24971@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223152226.GA2014@x61.redhat.com> <alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
 <alpine.LFD.2.02.1202240856370.1917@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Fri, 24 Feb 2012, Pekka Enberg wrote:

> Right. We should drop the sysctl and make it into a kernel command line 
> debugging option instead.
> 

I like how slub handles this when it can't allocate more slab with 
slab_out_of_memory() and has the added benefit of still warning even with 
__GFP_NORETRY that the oom killer is never called for.  If there's really 
a slab leak happening, there's a good chance that this diagnostic 
information is going to be emitted by the offending cache at some point in 
time if you're using slub.  This could easily be extended to slab.c, so 
it's even more reason not to include this type of information in the oom 
killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
