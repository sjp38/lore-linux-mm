Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 86AB36B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 03:33:55 -0400 (EDT)
Date: Wed, 26 Jun 2013 16:34:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
Message-ID: <20130626073400.GC29127@bbox>
References: <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, Kyungmin Park <kyungmin.park@samsung.com>

On Sat, Jun 22, 2013 at 01:51:17PM +0900, Hyunhee Kim wrote:
> And one more thing.
> 
> vmpressure sends all of the lower events than the level (current).
> 
> 155         list_for_each_entry(ev, &vmpr->events, node) {
> 156                 if (level >= ev->level) {
> 157                         eventfd_signal(ev->efd, 1);
> 158                         signalled = true;
> 159                 }
> 160         }
> 
> Isn't it wasteful?
> When we registered "low" and "critical", and the current level is
> critical, why should we signal "low" level together?
> If we receive "critical" only, can't we just assume "low" level at the
> user space?

Agree.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
