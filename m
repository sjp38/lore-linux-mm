Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BE15F6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 08:02:41 -0500 (EST)
Date: Thu, 28 Feb 2013 14:02:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: implement low limits
Message-ID: <20130228130237.GD6573@dhcp22.suse.cz>
References: <8121361952156@webcorp1g.yandex-team.ru>
 <20130227094054.GC16719@dhcp22.suse.cz>
 <17521361961576@webcorp1g.yandex-team.ru>
 <20130227161352.GF16719@dhcp22.suse.cz>
 <61661362049995@webcorp1g.yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <61661362049995@webcorp1g.yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: Johannes Weiner-Arquette <hannes@cmpxchg.org>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>

On Thu 28-02-13 15:13:15, Roman Gushchin wrote:
> 27.02.2013, 20:14, "Michal Hocko" <mhocko@suse.cz>:
> > On Wed 27-02-13 14:39:36, Roman Gushchin wrote:
[...]
> >>  2) cgroup's prioritization during global reclaim,
> >
> > Yes, group priorities sound like a useful feature not just for the
> > reclaim I would like it for oom selection as well.
> > I think that we shouldn't use any kind of limit for this task, though.
> 
> I'm thinking about them. Do you know, did someone any attempts to
> implement them?

I do not remember any patches but we have touched that topic in the
past. With no conclusion AFAIR. The primary issue is that this requires
good justification and nobody seemed to have a good use case - other
than "I can imagine this could be useful". But others might disagree and
provide such use cases...

[...]
> Actually, I don't like the name of soft limits - the word "soft". It's
> not clear from the name if it's lower or upper limit.

The name might be not the best one but it makes some sense.

> It's a little bit confusing that "limit" means upper limit, and "soft
> limit" means lower limit.

It is not a lower limit. It is basically a (soft) high limit for
memory contended situations. Now it just depends on what "memory
contended situation" means and this is an internal implementation thing
(e.g. reclaim only groups which are over soft limit to reduce the
contention). Changing it from best-effort to (almost) guarantee doesn't
change the semantic of the limit for users.

> Assuming it's possible to implement strict lower limit efficiently,
> how do you call them?

This is not about efficiency but rather about an user interface. If the
current one can be used we shouldn't introduce new or we will end up in
an unusable mess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
