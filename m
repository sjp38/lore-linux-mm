Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 89AF76B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 20:21:47 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so271122pbb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 17:21:46 -0800 (PST)
Date: Wed, 29 Feb 2012 17:21:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next] memcg: remove PCG_CACHE page_cgroup flag fix
In-Reply-To: <20120229194304.GF1673@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1202291718450.11821@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils> <alpine.LSU.2.00.1202282128500.4875@eggly.anvils> <20120229194304.GF1673@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Feb 2012, Johannes Weiner wrote:
> On Tue, Feb 28, 2012 at 09:30:17PM -0800, Hugh Dickins wrote:
> >  
> > +	anon = PageAnon(page);
> > +
> >  	switch (ctype) {
> >  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> > +		anon = true;
> > +		/* fallthrough */
> 
> If you don't mind, could you add a small comment on why this is the
> exception where we don't trust page->mapping?

Right, I'll send an incremental fix for that.

> 
> Other than that,
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
