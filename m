Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BA7506B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:45:24 -0400 (EDT)
Message-ID: <502DD9B7.5070604@parallels.com>
Date: Fri, 17 Aug 2012 09:42:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
References: <1345150417-30856-1-git-send-email-yinghan@google.com> <502D61E1.8040704@redhat.com> <20120816234157.GB2776@devil.redhat.com> <502DD35F.7080009@parallels.com> <CALWz4iw444F+odvnbrS_zfN_cNr0g+n3QBBTBtDGwZ8iJ89ujA@mail.gmail.com>
In-Reply-To: <CALWz4iw444F+odvnbrS_zfN_cNr0g+n3QBBTBtDGwZ8iJ89ujA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 09:40 AM, Ying Han wrote:
>> > 2) There is no memcg associated with the object, and then we should not
>> > bother with that object at all.
> In the patch I have, all objects are associated with *a* memcg. For
> those objects are charged to root or reparented to root,
> they do get associated with root and further memory pressure on root (
> global reclaim ) will be applied on those objects.
> 
For the practical purposes of what Dave is concerned about, "no memcg"
equals "root memcg", right? It still holds we would expect globally
accessed dentries to belong to root/no-memcg, and per-group pressure
would not get to them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
