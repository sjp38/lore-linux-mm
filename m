Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9A7C86B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:34:15 -0400 (EDT)
Date: Fri, 19 Oct 2012 19:34:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 04/18] slab: don't preemptively remove element from
 list in cache destroy
In-Reply-To: <1350656442-1523-5-git-send-email-glommer@parallels.com>
Message-ID: <0000013a7a84cb28-334eab12-33c4-4a92-bd9c-e5ad938f83d0-000000@email.amazonses.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri, 19 Oct 2012, Glauber Costa wrote:

> I, however, see no reason why we need to do so, since we are now locked
> during the whole deletion (which wasn't necessarily true before).  I
> propose a simplification in which we delete it only when there is no
> more going back, so we don't need to add it again.

Ok lets hope that holding the lock does not cause issues.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
