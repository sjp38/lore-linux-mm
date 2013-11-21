Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 934566B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 12:13:10 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so419567bkh.17
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 09:13:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id rl9si5026870bkb.67.2013.11.21.09.13.09
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 09:13:09 -0800 (PST)
Date: Thu, 21 Nov 2013 18:13:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131121171307.GB16703@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <20131120172119.GA1848@hp530>
 <20131120173357.GC18809@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311201937120.7167@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311201937120.7167@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vladimir Murzin <murzin.v@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-11-13 19:38:56, David Rientjes wrote:
> On Wed, 20 Nov 2013, Michal Hocko wrote:
> 
> > OK, I was a bit vague it seems. I meant to give zonelist, gfp_mask,
> > allocation order and nodemask parameters to the modules. So they have a
> > better picture of what is the OOM context.
> > What everything ould modules need to do an effective work is a matter
> > for discussion.
> > 
> 
> It's an interesting idea but unfortunately a non-starter for us because 
> our users don't have root,

I wouldn't see this as a problem. You can still have a module which
exports the notification interface you need. Including timeout
fallback. That would be trivial to implement and maybe more appropriate
to very specific environments. Moreover the global OOM handling wouldn't
be memcg bound.

> we create their memcg tree and then chown it to the user.  They can
> freely register for oom notifications but cannot load their own kernel
> modules for their own specific policy.

yes I see but that requires just a notification interface. It doesn't
have to be memcg specific, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
