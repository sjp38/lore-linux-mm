Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E0D076B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 18:12:55 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:12:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 14/14] Add documentation about the kmem controller
Message-Id: <20121017151254.e26607c5.akpm@linux-foundation.org>
In-Reply-To: <1350382611-20579-15-git-send-email-glommer@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
	<1350382611-20579-15-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012 14:16:51 +0400
Glauber Costa <glommer@parallels.com> wrote:

> +Kernel memory won't be accounted at all until limit on a group is set. This
> +allows for existing setups to continue working without disruption.  The limit
> +cannot be set if the cgroup have children, or if there are already tasks in the
> +cgroup.

What behaviour will usersapce see if "The limit cannot be set"? 
write() returns -EINVAL, something like that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
