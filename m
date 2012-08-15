Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 06A3E6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 14:25:05 -0400 (EDT)
Date: Wed, 15 Aug 2012 18:25:04 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
In-Reply-To: <CALWz4ixv8wfOqQ34CBLQ1jVdWoQc4-hQRkeRTb6U5x93gxjZZw@mail.gmail.com>
Message-ID: <000001392b881bf0-4cf7cb93-c142-4ddb-960a-b35390caca0f-000000@email.amazonses.com>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz>
 <000001392ac15404-43a3fd2c-a6d3-4985-b173-74bb586ad47c-000000@email.amazonses.com> <502BBC35.809@parallels.com> <000001392aec1926-72b3a631-1fb1-460c-803d-38c4405151e1-000000@email.amazonses.com>
 <CALWz4ixv8wfOqQ34CBLQ1jVdWoQc4-hQRkeRTb6U5x93gxjZZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 15 Aug 2012, Ying Han wrote:

> > How can you figure out which objects belong to which memcg? The ownerships
> > of dentries and inodes is a dubious concept already.
>
> I figured it out based on the kernel slab accounting.
> obj->page->kmem_cache->memcg

Well that is only the memcg which allocated it. It may be in use heavily
by other processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
