Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5E2DE6B0071
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:44:29 -0400 (EDT)
Date: Tue, 14 May 2013 16:44:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-ID: <20130514144427.GS5198@dhcp22.suse.cz>
References: <1368535118-27369-1-git-send-email-avagin@openvz.org>
 <20130514144031.GR5198@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514144031.GR5198@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 14-05-13 16:40:31, Michal Hocko wrote:
> On Tue 14-05-13 16:38:38, Andrey Vagin wrote:
> > struct memcg_cache_params has a union. Different parts of this union are
> > used for root and non-root caches. A part with destroying work is used only
> > for non-root caches.
> 
> but memcg_update_cache_size is called only for !root caches AFAICS
> (check memcg_update_all_caches)

Ohh, I am blind. memcg_update_all_caches skips all !root caches.
Then the patch looks correct. If Glauber has nothing against then thise
should be marked for stable (3.9)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
