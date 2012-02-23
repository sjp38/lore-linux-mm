Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 1FB7C6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 11:03:59 -0500 (EST)
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <20120223152226.GA2014@x61.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
	 <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
	 <20120223152226.GA2014@x61.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 23 Feb 2012 18:03:56 +0200
Message-ID: <1330013036.13624.78.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Thu, 2012-02-23 at 13:22 -0200, Rafael Aquini wrote:
> > I think this also gives another usecase for a possible /dev/mem_notify in 
> > the future: userspace could easily poll on an eventfd and wait for an oom 
> > to occur and then cat /proc/slabinfo to attain all this.  In other words, 
> > if we had this functionality (which I think we undoubtedly will in the 
> > future), this patch would be obsoleted.
> 
> Great! So, why not letting the time tell us if this feature will be obsoleted
> or not? I'd rather have this patch obsoleted by another one proven better, than
> just stay still waiting for something that might, or might not, happen in the
> future.

Sure.

I'm not really convinced such an ABI would be a full replacement for
this patch. There's certainly advantages to having all this visible in
syslog even if we'd have such a mechanism.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
