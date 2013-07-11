Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 3289A6B003B
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 11:42:55 -0400 (EDT)
Date: Thu, 11 Jul 2013 17:42:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [-] drop_caches-add-some-documentation-and-info-messsge.patch
 removed from -mm tree
Message-ID: <20130711154249.GL21667@dhcp22.suse.cz>
References: <51ddc31f.zotz9WDKK3lWXtDE%akpm@linux-foundation.org>
 <20130711073644.GB21667@dhcp22.suse.cz>
 <20130711123903.GF21667@dhcp22.suse.cz>
 <51DED095.7050803@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DED095.7050803@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Thu 11-07-13 08:34:45, Dave Hansen wrote:
> On 07/11/2013 05:39 AM, Michal Hocko wrote:
> >> I would turn this into a trace point but that would be much weaker
> >> because the one who is debugging an issue would have to think about
> >> enabling it before the affected workload starts. Which is not possible
> >> quite often. Having logs and looking at them afterwards is so
> >> _convinient_.
> 
> It would also be a lot weaker than the printk, but we could always add a
> counter for this stuff and at least dump it out in /proc/vmstat.  We
> wouldn't know who was doing it, but we'd at least know someone _was_
> doing it.  It would also have a decent chance of getting picked up by
> existing log collection systems.

But wouldn't be a counter more intrusive code wise? Dunno, but printk
serves it purpose and it doesn't add much to the code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
