Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 319FC6B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:24:20 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u74-v6so4470529oie.16
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:24:20 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h66-v6si18225789oia.375.2018.08.16.08.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 08:24:18 -0700 (PDT)
Date: Thu, 16 Aug 2018 08:24:03 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 1/2] mm: rework memcg kernel stack accounting
Message-ID: <20180816152356.GA5978@castle.DHCP.thefacebook.com>
References: <20180815003620.15678-1-guro@fb.com>
 <20180815163923.GA28953@cmpxchg.org>
 <20180815165513.GA26330@castle.DHCP.thefacebook.com>
 <20180815172044.GA29793@cmpxchg.org>
 <20180816063509.GS32645@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180816063509.GS32645@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Thu, Aug 16, 2018 at 08:35:09AM +0200, Michal Hocko wrote:
> On Wed 15-08-18 13:20:44, Johannes Weiner wrote:
> [...]
> > This is completely backwards.
> > 
> > We respect the limits unless there is a *really* strong reason not
> > to. The only situations I can think of is during OOM kills to avoid
> > memory deadlocks and during packet reception for correctness issues
> > (and because the network stack has its own way to reclaim memory).
> > 
> > Relying on some vague future allocations in the process's lifetime to
> > fail in order to contain it is crappy and unreliable. And unwinding
> > the stack allocation isn't too much complexity to warrant breaking the
> > containment rules here, even if it were several steps. But it looks
> > like it's nothing more than a 'goto free_stack'.
> > 
> > Please just fix this.
> 
> Thinking about it some more (sorry I should have done that in my
> previous reply already) I do agree with Johannes. We should really back
> off as soon as possible rather than rely on a future action because
> this is quite subtle and prone to unexpected behavior.

Ok, no problems, I'll address this in v2.

Thanks!
