Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 654686B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:28:23 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id c67-v6so2258386ywc.21
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:28:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 137-v6sor2473816ybd.21.2018.07.24.07.28.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 07:28:22 -0700 (PDT)
Date: Tue, 24 Jul 2018 07:28:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724142820.GL1934745@devbig577.frc2.facebook.com>
References: <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724142554.GQ28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Tue, Jul 24, 2018 at 04:25:54PM +0200, Michal Hocko wrote:
> I am sorry but I do not follow. Besides that modeling the behavior on
> panic_on_oom doesn't really sound very appealing to me. The knob is a
> crude hack mostly motivated by debugging (at least its non-global
> variants).

Hmm... we actually do use that quite a bit in production (moving away
from it gradually).

> So can we get back to workloads and shape the semantic on top of that
> please?

I didn't realize we were that off track.  Don't both map to what we
were discussing almost perfectly?

Thanks.

-- 
tejun
