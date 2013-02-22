Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 394DF6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 08:00:20 -0500 (EST)
Date: Fri, 22 Feb 2013 14:00:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130222130017.GB32285@dhcp22.suse.cz>
References: <20130222125217.GA32285@dhcp22.suse.cz>
 <20130222135442.ADFFF498@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130222135442.ADFFF498@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 22-02-13 13:54:42, azurIt wrote:
> >I am not sure how much time I'll have for this today but just to make
> >sure we are on the same page, could you point me to the two patches you
> >have applied in the mean time?
> 
> 
> Here:
> http://watchdog.sk/lkml/patches2

OK, looks correct.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
