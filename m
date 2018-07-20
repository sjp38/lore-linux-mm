Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 461FE6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 04:30:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a26-v6so2536951pgw.7
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 01:30:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u10-v6sor441036plu.19.2018.07.20.01.30.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 01:30:02 -0700 (PDT)
Date: Fri, 20 Jul 2018 01:30:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180717205221.GA19862@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807200126540.119737@chino.kir.corp.google.com>
References: <20180713221602.GA15005@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com> <20180713230545.GA17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com> <20180717173844.GB14909@castle.DHCP.thefacebook.com> <20180717194945.GM7193@dhcp22.suse.cz> <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com> <20180717205221.GA19862@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue, 17 Jul 2018, Roman Gushchin wrote:

> > This example is missing the usecase that I was referring to, i.e. killing 
> > all processes attached to a subtree because the limit on a common ancestor 
> > has been reached.
> > 
> > In your example, I would think that the memory.group_oom setting of /A and 
> > /A/B are meaningless because there are no processes attached to them.
> > 
> > IIUC, your proposal is to select the victim by whatever means, check the 
> > memory.group_oom setting of that victim, and then either kill the victim 
> > or all processes attached to that local mem cgroup depending on the 
> > setting.
> 
> Sorry, I don't get what are you saying.
> In cgroup v2 processes can't be attached to A and B.
> There is no such thing as "local mem cgroup" at all.
> 

Read the second paragraph, yes, there are no processes attached to either 
mem cgroup.  I'm saying "group oom" can take on two different meanings: 
one for the behavior when the mem cgroup reaches its limit (a direct 
ancestor with no processes attached) and one for the mem cgrop of the 
process chosen for oom kill.  I know that you care about the latter.  My 
*only* suggestion was for the tunable to take a string instead of a 
boolean so it is extensible for future use.  This seems like something so 
trivial.
