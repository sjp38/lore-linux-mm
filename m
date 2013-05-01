Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 335346B0177
	for <linux-mm@kvack.org>; Wed,  1 May 2013 05:05:47 -0400 (EDT)
Date: Wed, 1 May 2013 10:05:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 00/31] kmemcg shrinkers
Message-ID: <20130501090542.GQ6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <20130430224748.GP6415@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130430224748.GP6415@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Apr 30, 2013 at 11:47:48PM +0100, Mel Gorman wrote:
> I've queued another test to run just the patches up to and including
> "shrinker: Kill old ->shrink API".
> 

Oddities introduced prior to the memcg changes

In these, shrinker-v1r1 is the full series (middle column) and
nodeshrink-v1r1 is up to and including "shrinker: Kill old ->shrink API"

http://www.csn.ul.ie/~mel/postings/shrinker-20130501/global-dhp__pagereclaim-performance-ext3/hydra/report.html
http://www.csn.ul.ie/~mel/postings/shrinker-20130501/global-dhp__pagereclaim-performance-ext4/hydra/report.html
http://www.csn.ul.ie/~mel/postings/shrinker-20130501/global-dhp__pagereclaim-performance-xfs/hydra/report.html

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
