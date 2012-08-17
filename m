Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5C3C76B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:56:14 -0400 (EDT)
Message-ID: <502DDC3F.70902@parallels.com>
Date: Fri, 17 Aug 2012 09:53:03 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/6] memcg: restructure shrink_slab to walk memcg
 hierarchy
References: <1345150439-31003-1-git-send-email-yinghan@google.com> <502DD8D9.9050009@parallels.com> <CALWz4iwUeQNZr+JLmuvHZcRRp3+d__QuvsEP_diNivL_Qdc8Cg@mail.gmail.com> <502DDA65.60204@parallels.com> <CALWz4iyp3H_v9k8ipPSYMijWcrNWvCGGNQ-mDH3N5qYeMPLCPg@mail.gmail.com>
In-Reply-To: <CALWz4iyp3H_v9k8ipPSYMijWcrNWvCGGNQ-mDH3N5qYeMPLCPg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph
 Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 09:53 AM, Ying Han wrote:
>> > If the other shrinkers are not memcg aware, they will end up discarding
>> > random objects that may or may not have anything to do with the group
>> > under pressure, right?
> The main contributor of the accounted slabs and also reclaimable are
> vfs objects. Also we know dentry pins inode,
> so I wonder how bad the problem would be. Do you have specific example
> on which shrinker could cause the problem?
> 

I don't have any specific shrinkers in mind, but as you said yourself:
the main contributors comes from the VFS. So as long as we shrink the
VFS objects - and those will be memcg aware, why bother with the others?

It seems to me that we're just risking breaking isolation for very
little gain.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
