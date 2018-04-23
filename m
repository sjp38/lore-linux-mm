Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7269B6B0012
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:09:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o8-v6so18784457wra.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:09:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si4143345edt.292.2018.04.23.09.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 09:09:23 -0700 (PDT)
Date: Mon, 23 Apr 2018 10:09:20 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180423160920.GX17484@dhcp22.suse.cz>
References: <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
 <20180420082349.GW17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804212023120.84222@chino.kir.corp.google.com>
 <20180422131857.GI17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180422131857.GI17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 22-04-18 07:18:57, Michal Hocko wrote:
> On Sat 21-04-18 20:45:11, David Rientjes wrote:
[...]
> Maybe invoking the reaper as suggested by Tetsuo will help here. Maybe
> we will come up with something more smart. But I would like to have a
> stop gap solution for stable that is easy enough. And your patch is not
> doing that because it adds a very subtle dependency on the page lock.
> So please stop repeating your arguments all over and either come with
> an argument which proves me wrong and the lock_page dependency is not
> real or come with an alternative solution which doesn't make
> MMF_OOM_SKIP depend on the page lock.

I though I would give this a try but I am at a conference and quite
busy. Tetsuo are you willing to give it a try so that we have something
to compare and decide, please?
-- 
Michal Hocko
SUSE Labs
