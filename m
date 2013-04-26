Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 364AD6B0032
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 14:37:47 -0400 (EDT)
Received: by mail-qe0-f41.google.com with SMTP id b4so2983625qen.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 11:37:46 -0700 (PDT)
Date: Fri, 26 Apr 2013 11:37:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130426183741.GA25940@mtj.dyndns.org>
References: <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
 <20130423092944.GA8001@dhcp22.suse.cz>
 <20130423170900.GH12543@htj.dyndns.org>
 <20130426115120.GG31157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130426115120.GG31157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

Hey,

On Fri, Apr 26, 2013 at 01:51:20PM +0200, Michal Hocko wrote:
> Maybe I should have been more explicit about this but _yes I do agree_
> that a separate limit would work as well. I just do not want to

Heh, the point was more about what we shouldn't be doing, but, yeah,
it's good that we at least agree on something.  :)

> Anyway, I will think about cons and pros of the new limit. I think we
> shouldn't block the first 3 patches in the series which keep the current
> semantic and just change the internals to do the same thing. Do you
> agree?

As the merge window is coming right up, if it isn't something super
urgent, can we please hold it off until after the merge window?  It
would be really great if we can pin down the semantics of the knob
before doing anything.  Please.  I'll think / study more about it in
the coming weeks.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
