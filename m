Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 27D896B002B
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 06:47:25 -0400 (EDT)
Message-ID: <502B7D7F.3070603@parallels.com>
Date: Wed, 15 Aug 2012 14:44:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <20120814172540.GD6905@dhcp22.suse.cz> <502B6F00.8040207@parallels.com>
In-Reply-To: <502B6F00.8040207@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/15/2012 01:42 PM, Glauber Costa wrote:
>> Also, as I
>> > have mentioned in the other email in this thread. Why should we reclaim
>> > just because of kernel allocation when we are not reclaiming any of it
>> > because shrink_slab is ignored in the memcg reclaim.
> 
> Don't get too distracted by the fact that shrink_slab is ignored. It is
> temporary, and while this being ignored now leads to suboptimal
> behavior, it will 1st, only affect its users, and 2nd, not be disastrous.
> 
> I see it this as more or less on pair with the soft limit reclaim
> problem we had. It is not ideal, but it already provided functionality
> 

Okay, I sent the e-mail before finishing it... duh

What I meant in this last sentence, is that the situation while the
memcg-aware shrinkers doesn't land in the kernel is more or less the
same (obviously not exactly) as with the soft reclaim work. It is an
evolutionary approach that provides some functionality that is not yet
perfect but already solves lots of problems for people willing to live
with its temporary drawbacks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
