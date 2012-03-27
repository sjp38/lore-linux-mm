Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 625E56B007E
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 03:46:58 -0400 (EDT)
Date: Tue, 27 Mar 2012 09:46:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-ID: <20120327074652.GA31480@tiehlicka.suse.cz>
References: <20120322214944.27814.42039.stgit@zurg>
 <20120322215616.27814.40563.stgit@zurg>
 <20120326150429.GA22754@tiehlicka.suse.cz>
 <20120326151815.GA1820@cmpxchg.org>
 <20120326153131.GA22715@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1203261435110.3550@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203261435110.3550@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@parallels.com>

On Mon 26-03-12 14:39:49, Hugh Dickins wrote:
> On Mon, 26 Mar 2012, Michal Hocko wrote:
> > 
> > I guess that a note about changed ratio calculation should be added to
> > the changelog.
> 
> To the changelog of a patch which changes the ratio calculation, yes; but
> not to the changelog of this patch, which changes only the name of the test.

You are right. I somehow missed the important point that we had a
different ratio calculation since memcg naturalization...

Sorry for noise.

> 
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
