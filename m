Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 973D66B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 11:44:57 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u57so2461589wes.25
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 08:44:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eh10si4472447wib.58.2014.02.03.08.44.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 08:44:56 -0800 (PST)
Date: Mon, 3 Feb 2014 17:44:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 4/5] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140203164455.GL2495@dhcp22.suse.cz>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
 <1387295130-19771-5-git-send-email-mhocko@suse.cz>
 <20140130172906.GE6963@cmpxchg.org>
 <20140203133313.GF2495@dhcp22.suse.cz>
 <20140203161823.GJ6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140203161823.GJ6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 03-02-14 11:18:23, Johannes Weiner wrote:
> On Mon, Feb 03, 2014 at 02:33:13PM +0100, Michal Hocko wrote:
> > On Thu 30-01-14 12:29:06, Johannes Weiner wrote:
> > > On Tue, Dec 17, 2013 at 04:45:29PM +0100, Michal Hocko wrote:
[...]
> > > > In order to make this raceless we would need to hold rcu_read_lock since
> > > > css_tryget until res_counter_charge. This is not so easy unfortunately
> > > > because mem_cgroup_do_charge might sleep so we would need to do drop rcu
> > > > lock and do css_tryget tricks after each reclaim.
> > > 
> > > Yes, why not?
> > 
> > Although css_tryget is cheap these days I thought that a simple flag
> > check would be even heaper in this hot path. Changing the patch to use
> > css_tryget rather than offline check is trivial if you really think it
> > is better?
> 
> You already changed it to do css_tryget() on every single charge.

Fair point

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
