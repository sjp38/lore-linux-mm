Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 6BDAB6B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 15:55:54 -0400 (EDT)
Date: Tue, 29 May 2012 14:55:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
In-Reply-To: <4FC52612.5060006@parallels.com>
Message-ID: <alpine.DEB.2.00.1205291454030.2504@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290932530.4666@router.home> <4FC4F1A7.2010206@parallels.com> <alpine.DEB.2.00.1205291101580.6723@router.home>
 <4FC501E9.60607@parallels.com> <alpine.DEB.2.00.1205291222360.8495@router.home> <4FC506E6.8030108@parallels.com> <alpine.DEB.2.00.1205291424130.8495@router.home> <4FC52612.5060006@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 29 May 2012, Glauber Costa wrote:

> I don't know about cpusets in details, but at least with NUMA, this is not an
> apple-to-apple comparison. a NUMA node is not meant to contain you. A
> container is, and that is why it is called a container.

Cpusets contains sets of nodes. A cpusets "contains" nodes. These sets are
associated with applications.

> NUMA just means what is the *best* node to put my memory.
> Now, if you actually say, through you syscalls "this is the node it should
> live in", then you have a constraint, that to the best of my knowledge is
> respected.

Eith cpusets it means that memory needs to come from an assigned set of
nodes.

> Now isolation here, is done in the container boundary. (cgroups, to be
> generic).

Yes and with cpusets it is done at the cpuset boundary. Very much the
same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
