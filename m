Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6493A6B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 11:35:24 -0500 (EST)
Date: Fri, 28 Dec 2012 17:35:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121228163521.GB1455@dhcp22.suse.cz>
References: <20121210094318.GA6777@dhcp22.suse.cz>
 <20121210111817.F697F53E@pobox.sk>
 <20121210155205.GB6777@dhcp22.suse.cz>
 <20121217023430.5A390FD7@pobox.sk>
 <20121217163203.GD25432@dhcp22.suse.cz>
 <20121217192301.829A7020@pobox.sk>
 <20121217195510.GA16375@dhcp22.suse.cz>
 <20121218152223.6912832C@pobox.sk>
 <20121218152004.GA25208@dhcp22.suse.cz>
 <20121224143850.B611B3C3@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121224143850.B611B3C3@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 24-12-12 14:38:50, azurIt wrote:
> >OK, good to hear and fingers crossed. I will try to get back to the
> >original problem and a better solution sometimes early next year when
> >all the things settle a bit.
> 
> 
> Btw, i noticed one more thing when problem is happening (=when any
> cgroup is stucked), i fogot to mention it before, sorry :( . It's
> related to HDDs, something is slowing them down in a strange way. All
> services are working normally and i really cannot notice any slowness,
> the only thing which i noticed is affeceted is our backup software (
> www.Bacula.org ). When problem occurs at night, so it's happening when
> backup is running, backup is extremely slow and usually don't finish
> until i kill processes inside affected cgroup (=until i resolve the
> problem). Backup software is NOT doing big HDD bandwidth BUT it's
> doing quite huge number of disk operations (it needs to stat every
> file and directory). I believe that only speed of disk operations are
> affected and are very slow.

I would bet that this is caused by the blocked proceses in memcg oom
handler which hold i_mutex and the backup process wants to access the
same inode with an operation which requires the lock.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
