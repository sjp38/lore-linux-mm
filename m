Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id C69A66B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 13:45:55 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id jh10so3782741pab.31
        for <linux-mm@kvack.org>; Fri, 17 May 2013 10:45:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b4e0e499-b922-4e9c-a0f8-02318ddf3b9b@email.android.com>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
	<1368431172-6844-2-git-send-email-mhocko@suse.cz>
	<20130517160247.GA10023@cmpxchg.org>
	<20130517165712.GB12632@mtj.dyndns.org>
	<b4e0e499-b922-4e9c-a0f8-02318ddf3b9b@email.android.com>
Date: Fri, 17 May 2013 10:45:54 -0700
Message-ID: <CAOS58YP6qXM_mXvsCtGSViOZTw=mwnfUS7cZGAES8F4w5mCQdA@mail.gmail.com>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Hello,

On Fri, May 17, 2013 at 10:27 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
>>Hmmm... if the iteration is the problem, it shouldn't be difficult to
>>build list of children which should be iterated.  Would that make it
>>acceptable?
>
> You mean, a separate structure that tracks which groups are in excess of =
the limit?  Like the current tree? :)

Heh, yeah, realized that after writing it but it can be something much
simpler. ie. just linked list of children with soft limit configured.

> Kidding aside, yes, that would be better, and an unsorted list would prob=
ably be enough for the global case.

Yeap.

> To support target reclaim soft limits later on, we could maybe propagate =
tags upwards the cgroup tree when a group is in excess so that reclaim can =
be smarter about which subtrees to test for soft limits and which to skip d=
uring the soft limit pass.  The no-softlimit-set-anywhere case is then only=
 a single tag test in the root cgroup.
>
> But starting with the list would be simple enough, delete a bunch of code=
, come with the same performance improvements etc.

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
