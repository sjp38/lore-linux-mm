Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 5D5546B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 09:42:06 -0400 (EDT)
Date: Mon, 24 Sep 2012 13:42:05 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 05/16] consider a memcg parameter in
 kmem_create_cache
In-Reply-To: <50605500.5050606@parallels.com>
Message-ID: <00000139f8836571-6ddc9d5b-1d5f-4542-92f9-ad11070e5b7d-000000@email.amazonses.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-6-git-send-email-glommer@parallels.com> <20120921181458.GG7264@google.com> <506015E7.8030900@parallels.com> <00000139f84bdedc-aae672a6-2908-4cb8-8ed3-8fedf67a21af-000000@email.amazonses.com>
 <50605500.5050606@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, "<cgroups@vger.kernel.org>" <cgroups@vger.kernel.org>, "<kamezawa.hiroyu@jp.fujitsu.com>" <kamezawa.hiroyu@jp.fujitsu.com>, "<devel@openvz.org>" <devel@openvz.org>, "<linux-mm@kvack.org>" <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 24 Sep 2012, Glauber Costa wrote:

> But that is orthogonal, isn't it? People will still expect to see it in
> the old slabinfo file.

The current scheme for memory statistics is

/proc/meminfo contains global counters

/sys/devices/system/node/nodeX/meminfo

contains node specific counters.

The cgroups directory already contains various files. Adding a slabinfo
file would make sense and it could be found easily.

The sysfs hierachy /sys/kernel/slab could also show up there as a "slab"
directory under which all the details of the various caches would be
available and tunable. Very much in sync with the way the cgroups
directories operate.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
