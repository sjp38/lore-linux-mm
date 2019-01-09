Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F14A48E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 07:02:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so2917978eda.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 04:02:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15-v6si1194498ejj.234.2019.01.09.04.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 04:02:14 -0800 (PST)
Date: Wed, 9 Jan 2019 13:02:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190109120212.GT31793@dhcp22.suse.cz>
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190109110328.GS31793@dhcp22.suse.cz>
 <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 09-01-19 20:34:46, Tetsuo Handa wrote:
> On 2019/01/09 20:03, Michal Hocko wrote:
> > Tetsuo,
> > can you confirm that these two patches are fixing the issue you have
> > reported please?
> > 
> 
> My patch fixes the issue better than your "[PATCH 2/2] memcg: do not
> report racy no-eligible OOM tasks" does.

OK, so we are stuck again. Hooray!
-- 
Michal Hocko
SUSE Labs
