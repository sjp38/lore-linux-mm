Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 842E76B008C
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 01:09:42 -0500 (EST)
Received: by faas10 with SMTP id s10so3316332faa.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 22:09:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 24 Nov 2011 11:39:39 +0530
Message-ID: <CAKTCnzk0Jzq+o1Qv9hOO5ssO7U_xe1ZqUaWDhWEeJAQQPjPudg@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg fixlets for 3.3
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 23, 2011 at 9:12 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
>
> Here are some minor memcg-related cleanups and optimizations, nothing
> too exciting. =A0The bulk of the diffstat comes from renaming the
> remaining variables to describe a (struct mem_cgroup *) to "memcg".
> The rest cuts down on the (un)charge fastpaths, as people start to get
> annoyed by those functions showing up in the profiles of their their
> non-memcg workloads. =A0More is to come, but I wanted to get the more
> obvious bits out of the way.

Hi, Johannes

The renaming was a separate patch sent from Raghavendra as well, not
sure if you've seen it. What tests are you using to test these
patches?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
