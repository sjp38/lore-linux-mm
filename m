Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1D36B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 04:17:10 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so1623945ead.36
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 01:17:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si11226768eep.232.2014.01.17.01.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 01:17:09 -0800 (PST)
Date: Fri, 17 Jan 2014 10:17:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 -mm] mm, oom: prefer thread group leaders for display
 purposes
Message-ID: <20140117091706.GA5356@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1401151837560.1835@chino.kir.corp.google.com>
 <20140116070549.GL6963@cmpxchg.org>
 <alpine.DEB.2.02.1401152344560.14407@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1401152345330.14407@chino.kir.corp.google.com>
 <20140116142141.GF28157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401161447510.31228@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401161447510.31228@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-01-14 14:49:25, David Rientjes wrote:
> On Thu, 16 Jan 2014, Michal Hocko wrote:
> 
> > > When two threads have the same badness score, it's preferable to kill the 
> > > thread group leader so that the actual process name is printed to the 
> > > kernel log rather than the thread group name which may be shared amongst 
> > > several processes.
> > 
> > I am not sure I understand this. Is this about ->comm? If yes then why
> > couldn't the group leader do PR_SET_NAME?
> > 
> 
> Both comm and pid, we only display thread group leaders in the tasklist 
> dump of eligible processes, we want the killed message to specify from 
> which process.

OK, that makes sense now. I didn't think about dump_tasks and
consistency in the output.

> You're suggesting a thread group leader do PR_SET_NAME of all its threads 
> for readable oom killer output?  Lol.

No, I am not suggesting anything. I was just asking why is group leader
different in this regards becasue changelog didn't tell it and I didn't
put it together with dump_tasks.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
