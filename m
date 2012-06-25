Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 023106B01F7
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:44:42 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6939804dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:44:42 -0700 (PDT)
Date: Mon, 25 Jun 2012 10:44:37 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 01/11] memcg: Make it possible to use the stock for
 more than one page.
Message-ID: <20120625174437.GC3869@google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <1340633728-12785-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340633728-12785-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

Hey, Glauber.

Just a couple nits.

On Mon, Jun 25, 2012 at 06:15:18PM +0400, Glauber Costa wrote:
> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>

It would be nice to explain why this is being done.  Just a simple
statement like - "prepare for XXX" or "will be needed by XXX".

>  /*
> - * Try to consume stocked charge on this cpu. If success, one page is consumed
> - * from local stock and true is returned. If the stock is 0 or charges from a
> - * cgroup which is not current target, returns false. This stock will be
> - * refilled.
> + * Try to consume stocked charge on this cpu. If success, nr_pages pages are
> + * consumed from local stock and true is returned. If the stock is 0 or
> + * charges from a cgroup which is not current target, returns false.
> + * This stock will be refilled.

I hope this were converted to proper /** function comment with
arguments and return value description.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
