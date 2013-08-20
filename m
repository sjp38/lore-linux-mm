Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 11DF26B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 04:17:15 -0400 (EDT)
Date: Tue, 20 Aug 2013 10:17:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <20130820081713.GB31552@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
 <20130819074407.GA3396@dhcp22.suse.cz>
 <20130819095136.GB3396@dhcp22.suse.cz>
 <20130819154538.GA712@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130819154538.GA712@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon 19-08-13 11:45:38, Johannes Weiner wrote:
[...]
> If you want to make root_mem_cgroup always available, which is not a
> bad idea IMO and hch suggested during the lruvec patches, then make it
> properly in mecontrol.c and move the lruvec from struct zone in there.
> Then we can actually get rid of indirections and special cases, not
> add even more.
> 
> Or make the reclaim iterators return lruvecs.  They are so convoluted
> at this point that it would actually be an improvement to
> maintainability if they were separate code.
> 
> Maybe both.

Will think about it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
