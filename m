Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3767D6B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:16:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h15-v6so37425221qkj.17
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:16:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u188-v6si790555qka.330.2018.07.13.16.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:16:50 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:16:31 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180713231630.GB17467@castle.DHCP.thefacebook.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Fri, Jul 13, 2018 at 04:11:51PM -0700, David Rientjes wrote:
> On Fri, 13 Jul 2018, Roman Gushchin wrote:
> 
> > > All cgroup v2 files do not need to be boolean and the only way you can add 
> > > a subtree oom kill is to introduce yet another file later.  Please make it 
> > > tristate so that you can define a mechanism of default (process only), 
> > > local cgroup, or subtree, and so we can avoid adding another option later 
> > > that conflicts with the proposed one.  This should be easy.
> > 
> > David, we're adding a cgroup v2 knob, and in cgroup v2 a memory cgroup
> > either has a sub-tree, either attached processes. So, there is no difference
> > between local cgroup and subtree.
> > 
> 
> Uhm, what?  We're talking about a common ancestor reaching its limit, so 
> it's oom, and it has multiple immediate children with their own processes 
> attached.  The difference is killing all processes attached to the 
> victim's cgroup or all processes under the oom mem cgroup's subtree.
> 

But it's a binary decision, no?
If memory.group_oom set, the whole sub-tree will be killed. Otherwise not.
