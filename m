Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D80F46B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:06:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r15-v6so7948032lff.19
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:06:07 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m202-v6si12379111lfe.383.2018.07.13.16.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:06:05 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:05:48 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180713230545.GA17467@castle.DHCP.thefacebook.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Fri, Jul 13, 2018 at 03:39:15PM -0700, David Rientjes wrote:
> On Fri, 13 Jul 2018, Roman Gushchin wrote:
> 
> > > 
> > > One of the things that I really like about cgroup v2, though, is what 
> > > appears to be an implicit, but rather apparent, goal to minimize the 
> > > number of files for each controller.  It's very clean.  So I'd suggest 
> > > that we consider memory.group_oom, or however it is named, to allow for 
> > > future development.
> > > 
> > > For example, rather than simply being binary, we'd probably want the 
> > > ability to kill all eligible processes attached directly to the victim's 
> > > mem cgroup *or* all processes attached to its subtree as well.
> > > 
> > > I'd suggest it be implemented to accept a string, "default"/"process", 
> > > "local" or "tree"/"hierarchy", or better names, to define the group oom 
> > > mechanism for the mem cgroup that is oom when one of its processes is 
> > > selected as a victim.
> > 
> > I would prefer to keep it boolean to match the simplicity of cgroup v2 API.
> > In v2 hierarchy processes can't be attached to non-leaf cgroups,
> > so I don't see the place for the 3rd meaning.
> > 
> 
> All cgroup v2 files do not need to be boolean and the only way you can add 
> a subtree oom kill is to introduce yet another file later.  Please make it 
> tristate so that you can define a mechanism of default (process only), 
> local cgroup, or subtree, and so we can avoid adding another option later 
> that conflicts with the proposed one.  This should be easy.

David, we're adding a cgroup v2 knob, and in cgroup v2 a memory cgroup
either has a sub-tree, either attached processes. So, there is no difference
between local cgroup and subtree.
