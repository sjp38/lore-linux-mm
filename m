Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CF8956B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 07:54:14 -0500 (EST)
Date: Thu, 12 Jan 2012 13:54:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: add mlock statistic in memory.stat
Message-ID: <20120112125411.GG1042@tiehlicka.suse.cz>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326321668-5422-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Wed 11-01-12 14:41:08, Ying Han wrote:
> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> the metrics exported by memcg, especially is used together with "uneivctable"
> lru stat.

Could you describe when the unevictable has such a different meaning than
mlocked that it is unusable?

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
