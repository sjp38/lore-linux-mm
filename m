Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2F3536B0069
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 11:36:30 -0400 (EDT)
Date: Wed, 15 Aug 2012 15:36:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
In-Reply-To: <xr93obmcb2sh.fsf@gthelen.mtv.corp.google.com>
Message-ID: <000001392aedc393-52afb686-d95c-4ed7-9164-1388267fab06-000000@email.amazonses.com>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz>
 <000001392ac15404-43a3fd2c-a6d3-4985-b173-74bb586ad47c-000000@email.amazonses.com> <xr93obmcb2sh.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, yinghan@google.com

On Wed, 15 Aug 2012, Greg Thelen wrote:

> > You can already shrink the reclaimable slabs (dentries / inodes) via
> > calls to the subsystem specific shrinkers. Did Ying Han do anything to
> > go beyond that?
>
> cc: Ying
>
> The Google shrinker patches enhance prune_dcache_sb() to limit dentry
> pressure to a specific memcg.

Ok then its restricted to the reclaimable slab caches already. The main
issue to sort out then is who is the "owner" of an inode/dentry (if
something like that exists). If you separate the objects into different
pages then the objects may be cleanly separated at the price of more
memory use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
