Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3D3A96B00E5
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 09:47:46 -0400 (EDT)
Received: by mail-vb0-f43.google.com with SMTP id h11so1814397vbh.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 06:47:45 -0700 (PDT)
Date: Wed, 7 Aug 2013 09:47:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: Limit the number of events registered on
 oom_control
Message-ID: <20130807134741.GF27006@htj.dyndns.org>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <1375874907-22013-2-git-send-email-mhocko@suse.cz>
 <20130807130836.GB27006@htj.dyndns.org>
 <20130807133746.GI8184@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807133746.GI8184@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

Hello,

On Wed, Aug 07, 2013 at 03:37:46PM +0200, Michal Hocko wrote:
> > It isn't different from listening from epoll, for example.
> 
> epoll limits the number of watchers, no?

Not that I know of.  It'll be limited by max open fds but I don't
think there are other limits.  Why would there be?

> > If there needs to be kernel memory limit, shouldn't that be handled by
> > kmemcg?
> 
> kmemcg would surely help but turning it on just because of potential
> abuse of the event registration API sounds like an overkill.
> 
> I think having a cap for user trigable kernel resources is a good thing
> in general.

I don't know.  It's just very arbitrary because listening to events
itself isn't (and shouldn't) be something which consumes resource
which isn't attributed to the listener and this artificially creates a
global resource.  The problem with memory usage event is breaching
that rule with shared kmalloc() so putting well-defined limit on it is
fine but the latter two create additional artificial restrictions
which are both unnecessary and unconventional.  No?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
