Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BE75F6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:47:58 -0400 (EDT)
Date: Wed, 15 Aug 2012 14:47:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
In-Reply-To: <20120815123931.GF23985@dhcp22.suse.cz>
Message-ID: <000001392ac15404-43a3fd2c-a6d3-4985-b173-74bb586ad47c-000000@email.amazonses.com>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 15 Aug 2012, Michal Hocko wrote:

> > That is not what the kernel does, in general. We assume that if he wants
> > that memory and we can serve it, we should. Also, not all kernel memory
> > is unreclaimable. We can shrink the slabs, for instance. Ying Han
> > claims she has patches for that already...
>
> Are those patches somewhere around?

You can already shrink the reclaimable slabs (dentries / inodes) via
calls to the subsystem specific shrinkers. Did Ying Han do anything to
go beyond that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
