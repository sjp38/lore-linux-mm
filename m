Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id AAC3D6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 01:57:43 -0500 (EST)
Received: by lamf4 with SMTP id f4so3338323lam.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 22:57:41 -0800 (PST)
Date: Fri, 24 Feb 2012 08:57:37 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1202240856370.1917@tux.localdomain>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223152226.GA2014@x61.redhat.com> <alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Thu, 23 Feb 2012, David Rientjes wrote:
> > Great! So, why not letting the time tell us if this feature will be obsoleted
> > or not? I'd rather have this patch obsoleted by another one proven better, than
> > just stay still waiting for something that might, or might not, happen in the
> > future.
> 
> Because (1) you're adding a sysctl that we don't want to obsolete and 
> remove from the kernel that someone will come to depend on and then have 
> to find an alternative solution like /dev/mem_notify, and (2) people parse 
> messages like this that are emitted to the kernel log that we don't want 
> to break in the future.
> 
> So NACK on this approach.

Right. We should drop the sysctl and make it into a kernel command line 
debugging option instead.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
