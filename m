Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 22F476B0034
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:12:37 -0400 (EDT)
Message-ID: <517688F0.7010407@parallels.com>
Date: Tue, 23 Apr 2013 17:13:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: softlimit on internal nodes
References: <20130421022321.GE19097@mtj.dyndns.org> <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com> <20130422042445.GA25089@mtj.dyndns.org> <20130422153730.GG18286@dhcp22.suse.cz> <20130422154620.GB12543@htj.dyndns.org> <20130422155454.GH18286@dhcp22.suse.cz> <CANN689Hz5A+iMM3T76-8RCh8YDnoGrYBvtjL_+cXaYRR0OkGRQ@mail.gmail.com> <51765FB2.3070506@parallels.com> <20130423114020.GC8001@dhcp22.suse.cz> <CANN689FaGBi+LmdoSGBf3D9HmLD8Emma1_M3T1dARSD6=75B0w@mail.gmail.com> <20130423130627.GG8001@dhcp22.suse.cz>
In-Reply-To: <20130423130627.GG8001@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>

On 04/23/2013 05:06 PM, Michal Hocko wrote:
> On Tue 23-04-13 05:51:36, Michel Lespinasse wrote:
> [...]
>> The issue I see is that even when people configure soft limits B+C <
>> A, your current proposal still doesn't "leave the other alone" as
>> Glauber and I think we should.
> 
> If B+C < A then B resp. C get reclaimed only if A is over the limit
> which means that it couldn't reclaimed enough to get bellow the limit
> when we bang on it before B and C. We can update the implementation
> later to be more clever in situations like this but this is not that
> easy because once we get away from the round robin over the tree then we
> might end up having other issues - like unfairness etc... That's why I
> wanted to have this as simple as possible.
> 
Nobody is opposing this, Michal.

What people are opposing is you saying that the children should be
reclaimed *regardless* of their softlimit when the parent is over their
soft limit. Someone, specially you, saying this, highly threatens
further development in this direction.

It doesn't really matter if your current set is doing this, simply
everybody already agreed that you are moving in a good direction.

If you believe that it is desired to protect the children from reclaim
in situation in which the offender is only one of the children and that
can be easily identified, please state that clearly.

Since nobody is really opposing your patchset, that is enough for the
discussion to settle. (Can't say how others feel, but can say about
myself, and guess about others)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
