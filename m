Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D74DB6B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 11:11:19 -0400 (EDT)
Date: Sun, 14 Apr 2013 08:11:14 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130414151114.GG6478@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <20130414004252.GA1330@suse.de>
 <20130414143420.GA6478@dhcp22.suse.cz>
 <20130414145532.GB5701@cmpxchg.org>
 <20130414150455.GE6478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130414150455.GE6478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>

On Sun 14-04-13 08:04:55, Michal Hocko wrote:
> On Sun 14-04-13 10:55:32, Johannes Weiner wrote:
> > However, that parent is not necessarily the root of the hierarchy that
> > is being reclaimed and you might have multiple of such sub-hierarchies
> > in excess.  To handle all the corner cases, I'd expect the
> > relationship checking to get really complicated.
> 
> We could always return the leftmost and get to others as the iteration
> continues. I will try to think about it some more. I do not think we
> would save a lot but it looks like a neat idea.

Hmm, scratch that. Leftmost doesn't make much sense as we are going
bottom up...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
