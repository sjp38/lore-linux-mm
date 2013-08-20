Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 805C66B0034
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 04:14:39 -0400 (EDT)
Date: Tue, 20 Aug 2013 10:14:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <20130820081436.GA31552@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
 <20130819074407.GA3396@dhcp22.suse.cz>
 <20130819095136.GB3396@dhcp22.suse.cz>
 <alpine.LNX.2.00.1308191154230.1505@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1308191154230.1505@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon 19-08-13 12:28:31, Hugh Dickins wrote:
[...]
> I don't see any point in introducing it now, solely for the
> mem_cgroup_iter_cond() loop: that's better served by my patch.

OK. Fair enough. I thougt it would be at least clear if we accidently
added a code which would require touching the non-existing memcg for
!MEMCG case because that wouldn't even compile with this patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
