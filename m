Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9B6786B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 12:44:43 -0400 (EDT)
Received: by mail-da0-f42.google.com with SMTP id n15so1091914dad.1
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 09:44:42 -0700 (PDT)
Date: Wed, 20 Mar 2013 09:40:48 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
Message-ID: <20130320164047.GA22177@lizard.fhda.edu>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-3-git-send-email-glommer@parallels.com>
 <20130319124650.GE7869@dhcp22.suse.cz>
 <20130319125509.GF7869@dhcp22.suse.cz>
 <51495F35.9040302@parallels.com>
 <20130320080347.GE20045@dhcp22.suse.cz>
 <51496E71.5010707@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <51496E71.5010707@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Wed, Mar 20, 2013 at 12:08:17PM +0400, Glauber Costa wrote:
[...]
> >> The fact that I keep bypassing when hierarchy is present, it is
> >> more of a reuse of the infrastructure since it's there anyway.
> >>
> >> Also, I would like the root memcg to be usable, albeit cheap, for
> >> projects like memory pressure notifications.
> >  
> > root memcg without any childre, right?
> > 
> yes, of course.

Just want to raise a voice of support for this one. Thanks to Glauber's
efforts, we might not need another memory pressure interface for
CONFIG_MEMCG=n case, since we might have CONFIG_MEMCG=y that will be super
cheap when used with just a root memcg w/o children, and still usable for
mem pressure. So this particular scenario is actually in demand[1].

Thanks!

Anton

[1] http://lkml.indiana.edu/hypermail/linux/kernel/1302.2/03173.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
