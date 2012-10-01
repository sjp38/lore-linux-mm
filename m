Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A33786B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 08:36:56 -0400 (EDT)
Date: Mon, 1 Oct 2012 14:36:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 09/13] memcg: kmem accounting lifecycle management
Message-ID: <20121001123654.GJ8622@dhcp22.suse.cz>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-10-git-send-email-glommer@parallels.com>
 <20121001121553.GG8622@dhcp22.suse.cz>
 <50698C97.70703@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50698C97.70703@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 01-10-12 16:29:11, Glauber Costa wrote:
> On 10/01/2012 04:15 PM, Michal Hocko wrote:
> > Based on the previous discussions I guess this one will get reworked,
> > right?
> > 
> 
> Yes, but most of it stayed. The hierarchy part is gone, but because we
> will still have kmem pages floating around (potentially), I am still
> using the mark_dead() trick with the corresponding get when kmem_accounted.

Is it OK if I hold on with the review of this one until the next
version?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
