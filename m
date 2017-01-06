Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D34876B026B
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:19:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id iq1so65855669wjb.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:19:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t36si1093536wrc.56.2017.01.06.08.19.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 08:19:46 -0800 (PST)
Date: Fri, 6 Jan 2017 17:19:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Message-ID: <20170106161944.GW5556@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20170106160743.GU5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106160743.GU5556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 06-01-17 17:07:43, Michal Hocko wrote:
> On Fri 06-01-17 07:39:14, Eric Dumazet wrote:
> > On Fri, Jan 6, 2017 at 7:20 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > Hi Eric,
> > > I am currently checking kmalloc with vmalloc fallback users and convert
> > > them to a new kvmalloc helper [1]. While I am adding a support for
> > > __GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use
> > > __GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef
> > > ("pkt_sched: fq: more robust memory allocation") doesn't mention
> > > anything. Could you clarify this please?
> > >
> > > Thanks!
> > 
> > I guess this question applies to all __GFP_REPEAT usages in net/ ?
> 
> I am _currently_ interested only in those which have vmalloc fallback
> and cannot see more of them. Maybe my git grep foo needs some help.

I was obviously blind...
---
