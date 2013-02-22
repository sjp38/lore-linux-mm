Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0244F6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 07:52:21 -0500 (EST)
Date: Fri, 22 Feb 2013 13:52:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130222125217.GA32285@dhcp22.suse.cz>
References: <20130208123854.GB7557@dhcp22.suse.cz>
 <20130208145616.FB78CE24@pobox.sk>
 <20130208152402.GD7557@dhcp22.suse.cz>
 <20130208165805.8908B143@pobox.sk>
 <20130208171012.GH7557@dhcp22.suse.cz>
 <20130208220243.EDEE0825@pobox.sk>
 <20130210150310.GA9504@dhcp22.suse.cz>
 <20130210174619.24F20488@pobox.sk>
 <20130211112240.GC19922@dhcp22.suse.cz>
 <20130222092332.4001E4B6@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130222092332.4001E4B6@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi,

On Fri 22-02-13 09:23:32, azurIt wrote:
[...]
> sorry that i didn't response for a while. Today i installed kernel
> with your two patches and i'm running it now.

I am not sure how much time I'll have for this today but just to make
sure we are on the same page, could you point me to the two patches you
have applied in the mean time?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
