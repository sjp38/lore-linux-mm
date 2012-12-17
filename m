Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BFD4A6B005A
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 14:55:24 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so2746342eaa.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 11:55:23 -0800 (PST)
Date: Mon, 17 Dec 2012 20:55:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121217195510.GA16375@dhcp22.suse.cz>
References: <20121205141722.GA9714@dhcp22.suse.cz>
 <20121206012924.FE077FD7@pobox.sk>
 <20121206095423.GB10931@dhcp22.suse.cz>
 <20121210022038.E6570D37@pobox.sk>
 <20121210094318.GA6777@dhcp22.suse.cz>
 <20121210111817.F697F53E@pobox.sk>
 <20121210155205.GB6777@dhcp22.suse.cz>
 <20121217023430.5A390FD7@pobox.sk>
 <20121217163203.GD25432@dhcp22.suse.cz>
 <20121217192301.829A7020@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121217192301.829A7020@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 17-12-12 19:23:01, azurIt wrote:
> >[Ohh, I am really an idiot. I screwed the first patch]
> >-       bool oom = true;
> >+       bool oom = !(gfp_mask | GFP_MEMCG_NO_OOM);
> >
> >Which obviously doesn't work. It should read !(gfp_mask &GFP_MEMCG_NO_OOM).
> >  No idea how I could have missed that. I am really sorry about that.
> 
> 
> :D no problem :) so, now it should really work as expected and
> completely fix my original problem?

It should mitigate the problem. The real fix shouldn't be that specific
(as per discussion in other thread). The chance this will get upstream
is not big and that means that it will not get to the stable tree
either.

> is it safe to apply it on 3.2.35?

I didn't check what are the differences but I do not think there is
anything to conflict with it.

> Thank you very much!

HTH

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
