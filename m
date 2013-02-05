Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6E76B6B0010
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 08:49:47 -0500 (EST)
Date: Tue, 5 Feb 2013 14:49:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130205134937.GA22804@dhcp22.suse.cz>
References: <20121217192301.829A7020@pobox.sk>
 <20121217195510.GA16375@dhcp22.suse.cz>
 <20121218152223.6912832C@pobox.sk>
 <20121218152004.GA25208@dhcp22.suse.cz>
 <20121224142526.020165D3@pobox.sk>
 <20121228162209.GA1455@dhcp22.suse.cz>
 <20121230020947.AA002F34@pobox.sk>
 <20121230110815.GA12940@dhcp22.suse.cz>
 <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130125163130.GF4721@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 25-01-13 17:31:30, Michal Hocko wrote:
> On Fri 25-01-13 16:07:23, azurIt wrote:
> > Any news? Thnx!
> 
> Sorry, but I didn't get to this one yet.

Sorry, to get back to this that late but I was busy as hell since the
beginning of the year.

Has the issue repeated since then?

You said you didn't apply other than the above mentioned patch. Could
you apply also debugging part of the patches I have sent?
In case you don't have it handy then it should be this one:
---
