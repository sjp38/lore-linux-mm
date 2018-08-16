Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FABA6B000D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 02:35:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t7-v6so1476381edh.20
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 23:35:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5-v6si286101edm.2.2018.08.15.23.35.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 23:35:11 -0700 (PDT)
Date: Thu, 16 Aug 2018 08:35:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Message-ID: <20180816063509.GS32645@dhcp22.suse.cz>
References: <20180815003620.15678-1-guro@fb.com>
 <20180815163923.GA28953@cmpxchg.org>
 <20180815165513.GA26330@castle.DHCP.thefacebook.com>
 <20180815172044.GA29793@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815172044.GA29793@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed 15-08-18 13:20:44, Johannes Weiner wrote:
[...]
> This is completely backwards.
> 
> We respect the limits unless there is a *really* strong reason not
> to. The only situations I can think of is during OOM kills to avoid
> memory deadlocks and during packet reception for correctness issues
> (and because the network stack has its own way to reclaim memory).
> 
> Relying on some vague future allocations in the process's lifetime to
> fail in order to contain it is crappy and unreliable. And unwinding
> the stack allocation isn't too much complexity to warrant breaking the
> containment rules here, even if it were several steps. But it looks
> like it's nothing more than a 'goto free_stack'.
> 
> Please just fix this.

Thinking about it some more (sorry I should have done that in my
previous reply already) I do agree with Johannes. We should really back
off as soon as possible rather than rely on a future action because
this is quite subtle and prone to unexpected behavior.

-- 
Michal Hocko
SUSE Labs
