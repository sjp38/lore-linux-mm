Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 33CEF6B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 12:08:00 -0400 (EDT)
Date: Tue, 25 Jun 2013 18:07:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
Message-ID: <20130625160756.GB10617@dhcp22.suse.cz>
References: <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621162743.GA2837@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

Hi,

On Sat 22-06-13 01:27:43, Minchan Kim wrote:
> > > Question.
> > > 
> > > 1. user: set critical edge
> > > 2. kernel: memory is tight and trigger event with critical
> > > 3. user: kill a program when he receives a event
> > > 4. kernel: memory is very tight again and want to trigger a event
> > >    with critical but fail because last_level was critical and it was edge.
> > > 
> > > Right?
> > 
> > yes, this is the risk of the edge triggering and the user has to be
> > prepared for that. I still think that it makes some sense to have the
> > two modes.
> 
> I'm not sure it's good idea.
> How could user overcome above problem?

Well, if the interface is proposed to workaround issues of the current
implementation then it is surely not a good path. 

I was referring to a concept of edge triggering which makes some sense
to me.  Consider one shot actions that should start/stop a certain
action when the level changes (e.g. very popular notification to admin).

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
