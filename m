Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7738B6B006C
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 13:26:26 -0400 (EDT)
Date: Wed, 15 Aug 2012 17:26:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
In-Reply-To: <502BC1B1.3010807@parallels.com>
Message-ID: <000001392b526a8a-3ec5f35e-405f-47f5-a7c1-ec0cae473fe9-000000@email.amazonses.com>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz>
 <000001392ac15404-43a3fd2c-a6d3-4985-b173-74bb586ad47c-000000@email.amazonses.com> <502BBC35.809@parallels.com> <000001392aec1926-72b3a631-1fb1-460c-803d-38c4405151e1-000000@email.amazonses.com> <502BC1B1.3010807@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 15 Aug 2012, Glauber Costa wrote:

> Remember we copy over the metadata and create copies of the caches
> per-memcg. Therefore, a dentry belongs to a memcg if it was allocated
> from the slab pertaining to that memcg.

The dentry could be used by other processes in the system though. F.e.
directory names could easily be created by one process and then used by a
multitude of others.

> It is not 100 % accurate, but it is good enough.

Lets hope that is true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
