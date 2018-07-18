Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF8856B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:19:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s18-v6so1603744edr.15
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 01:19:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m90-v6si2921509ede.52.2018.07.18.01.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 01:19:02 -0700 (PDT)
Date: Wed, 18 Jul 2018 10:19:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180718081901.GQ7193@dhcp22.suse.cz>
References: <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue 17-07-18 13:41:33, David Rientjes wrote:
[...]
> Thus, the semantic would be: if oom mem cgroup is "tree", kill all 
> processes in subtree; otherwise, it can be "cgroup" or "process" to 
> determine what is oom killed depending on the victim selection.

Why should be an intermediate node any different from the leaf. If you
want to tear down the whole subtree, just make it oom_cgroup = true and
be done with that. Why do we even need to call it tree?
 
> Having the "tree" behavior could definitely be implemented as a separate 
> tunable; but then then value of /A/memory.group_oom and 
> /A/B/memory.group_oom are irrelevant and, to me, seems like it would be 
> more confusing.

I am sorry, I do not follow. How are the following two different?
A (tree)	A (group)
|		|
B (tree)	B (group)
|		|
C (process)	C (group=false)

-- 
Michal Hocko
SUSE Labs
