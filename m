Date: Thu, 29 May 2008 21:46:26 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 0/2] memcg: simple hierarchy (v2)
Message-ID: <20080529214626.00da9bda@bree.surriel.com>
In-Reply-To: <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 May 2008 10:43:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Implemented Policy:
>   - parent overcommits all children
>      parent->usage = resource used by itself + resource moved to children.
>      Of course, parent->limit > parent->usage. 
>   - when child's limit is set, the resouce moves.
>   - no automatic resource moving between parent <-> child

> Why this is enough ?
>   - A middleware can do various kind of resource balancing only by reseting "limit"
>     in userland.

I like this idea.  The alternative could mean having a page live
on multiple cgroup LRU lists, not just the zone LRU and the one
cgroup LRU, and drastically increasing run time overhead.

Swapping memory in and out is horrendously slow anyway, so the
idea of having a daemon adjust the limits on the fly should work
just fine.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
