Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A57D56B0085
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:51:43 -0400 (EDT)
Date: Fri, 19 Oct 2012 19:51:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 16/18] slab: propagate tunables values
In-Reply-To: <1350656442-1523-17-git-send-email-glommer@parallels.com>
Message-ID: <0000013a7a94c439-825659cc-8e6a-4905-909c-db1b230a4086-000000@email.amazonses.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-17-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri, 19 Oct 2012, Glauber Costa wrote:

> SLAB allows us to tune a particular cache behavior with tunables.
> When creating a new memcg cache copy, we'd like to preserve any tunables
> the parent cache already had.

SLAB and SLUB allow tuning. Could you come up with some way to put these
things into slab common and make it flexible so that the tuning could be
used for future allocators (like SLAM etc)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
