Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDFE6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 15:49:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x21-v6so990367eds.2
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:49:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18-v6si1531750edf.0.2018.07.17.12.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 12:49:47 -0700 (PDT)
Date: Tue, 17 Jul 2018 21:49:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180717194945.GM7193@dhcp22.suse.cz>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131423230.194789@chino.kir.corp.google.com>
 <20180713221602.GA15005@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131535420.202408@chino.kir.corp.google.com>
 <20180713230545.GA17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717173844.GB14909@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue 17-07-18 10:38:45, Roman Gushchin wrote:
[...]
> Let me show my proposal on examples. Let's say we have the following hierarchy,
> and the biggest process (or the process with highest oom_score_adj) is in D.
> 
>   /
>   |
>   A
>   |
>   B
>  / \
> C   D
> 
> Let's look at different examples and intended behavior:
> 1) system-wide OOM
>   - default settings: the biggest process is killed
>   - D/memory.group_oom=1: all processes in D are killed
>   - A/memory.group_oom=1: all processes in A are killed
> 2) memcg oom in B
>   - default settings: the biggest process is killed
>   - A/memory.group_oom=1: the biggest process is killed

Huh? Why would you even consider A here when the oom is below it?
/me confused

>   - B/memory.group_oom=1: all processes in B are killed

    - B/memory.group_oom=0 &&
>   - D/memory.group_oom=1: all processes in D are killed

What about?
    - B/memory.group_oom=1 && D/memory.group_oom=0

Is this a sane configuration?
-- 
Michal Hocko
SUSE Labs
