Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E0F326B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 16:04:09 -0500 (EST)
Received: by iajr24 with SMTP id r24so11951869iaj.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 13:04:09 -0800 (PST)
Date: Wed, 7 Mar 2012 13:04:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
In-Reply-To: <4F5742AF.7090409@parallels.com>
Message-ID: <alpine.DEB.2.00.1203071303080.7640@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <4F5742AF.7090409@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 7 Mar 2012, Glauber Costa wrote:

> > I don't suspect we'll be very popular if we try to remove it, I can see
> > how it would be useful when BUG() is used when the problem isn't really
> > fatal (to stop something like disk corruption), like the above case isn't.
> I guess everyone that is able to track the problem back to an instance of
> BUG(), be skilled enough to be sure it is not fatal, and then recompile the
> kernel with this option (that I bet many of us didn't even know that existed),
> can very well just change it to a WARN_*, (and maybe patch it upstream).
> 

That's the point of the next patch which changes this to a WARN_ON_ONCE(1) 
because all of the BUG()'s that it changes in mm/mempolicy.c aren't fatal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
