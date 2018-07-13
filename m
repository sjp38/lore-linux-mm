Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4516B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:11:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so20571605plv.0
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:11:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k85-v6sor7824540pfj.132.2018.07.13.16.11.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 16:11:52 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:11:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180713230545.GA17467@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com> <20180713221602.GA15005@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Fri, 13 Jul 2018, Roman Gushchin wrote:

> > All cgroup v2 files do not need to be boolean and the only way you can add 
> > a subtree oom kill is to introduce yet another file later.  Please make it 
> > tristate so that you can define a mechanism of default (process only), 
> > local cgroup, or subtree, and so we can avoid adding another option later 
> > that conflicts with the proposed one.  This should be easy.
> 
> David, we're adding a cgroup v2 knob, and in cgroup v2 a memory cgroup
> either has a sub-tree, either attached processes. So, there is no difference
> between local cgroup and subtree.
> 

Uhm, what?  We're talking about a common ancestor reaching its limit, so 
it's oom, and it has multiple immediate children with their own processes 
attached.  The difference is killing all processes attached to the 
victim's cgroup or all processes under the oom mem cgroup's subtree.
