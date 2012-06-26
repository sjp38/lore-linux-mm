Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 30F3E6B009F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:41:06 -0400 (EDT)
Message-ID: <4FE9C961.4030507@parallels.com>
Date: Tue, 26 Jun 2012 18:38:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
References: <1340717428-9009-1-git-send-email-glommer@parallels.com> <20120626141127.GA27816@cmpxchg.org> <1340720366.21991.84.camel@twins> <20120626143818.GB27816@cmpxchg.org>
In-Reply-To: <20120626143818.GB27816@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, cgroups@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On 06/26/2012 06:38 PM, Johannes Weiner wrote:
> On Tue, Jun 26, 2012 at 04:19:26PM +0200, Peter Zijlstra wrote:
>> On Tue, 2012-06-26 at 16:11 +0200, Johannes Weiner wrote:
>>>
>>> Should the warning be emitted for any memcg, not just the parent?  If
>>> somebody takes notice of the changed semantics, it's better to print
>>> the warning on the first try to disable hierarchies instead of holding
>>> back until they walk up the tree and try to change it in the root.
>>> Still forbid disabling at lower levels, just be more eager to inform
>>> the people trying it.
>>
>> *blink* You mean you can mix-and-match use_hierarchy over the hierarchy?
>> Can I have some of those drugs? It must be strong and powerful stuff
>> that.
>
> You can create root/a/b/c/d/e and enable hierarchy in b, which ends up
> treating (a) and (b+children) like siblings even though they nest in
> the cgroup fs.
>
> Yes, drugs.
>
> But you can't disable the hierarchy if you have a hierarchy-enabled
> parent, which we try to make the new default.  So in case somebody has
> an existing setup that happened to nest group directories without
> hierarchy and so never used memory.use_hierarchy before, they'll
> probably try to disable it where it bothers them,

The only problem is that it was already disallowed way before, since as
you said yourself, you can't disable hierarchy if you have a hierarchy
enabled parent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
