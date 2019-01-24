Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBB5B8E0084
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 12:01:21 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so4276986plg.6
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 09:01:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a81si22460519pfj.195.2019.01.24.09.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 09:01:20 -0800 (PST)
Date: Thu, 24 Jan 2019 18:01:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190124170117.GS4087@dhcp22.suse.cz>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124160009.GA12436@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu 24-01-19 11:00:10, Johannes Weiner wrote:
[...]
> We cannot fully eliminate a risk for regression, but it strikes me as
> highly unlikely, given the extremely young age of cgroup2-based system
> management and surrounding tooling.

I am not really sure what you consider young but this interface is 4.0+
IIRC and the cgroup v2 is considered stable since 4.5 unless I
missrememeber and that is not a short time period in my book. Changing
interfaces now represents a non-trivial risk and so far I haven't heard
any actual usecase where the current semantic is actually wrong.
Inconsistency on its own is not a sufficient justification IMO.
-- 
Michal Hocko
SUSE Labs
