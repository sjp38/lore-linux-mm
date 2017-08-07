Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBC56B02F4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:22:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g21so1046450lfg.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:22:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m29si3177444lfj.628.2017.08.07.07.22.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 07:22:24 -0700 (PDT)
Date: Mon, 7 Aug 2017 16:21:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm, oom: do not grant oom victims full memory
 reserves access
Message-ID: <20170807142121.GK32434@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727090357.3205-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 27-07-17 11:03:55, Michal Hocko wrote:
> Hi,
> this is a part of a larger series I posted back in Oct last year [1]. I
> have dropped patch 3 because it was incorrect and patch 4 is not
> applicable without it.
> 
> The primary reason to apply patch 1 is to remove a risk of the complete
> memory depletion by oom victims. While this is a theoretical risk right
> now there is a demand for memcg aware oom killer which might kill all
> processes inside a memcg which can be a lot of tasks. That would make
> the risk quite real.
> 
> This issue is addressed by limiting access to memory reserves. We no
> longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
> instead. See Patch 1 for more details. Patch 2 is a trivial follow up
> cleanup.
> 
> I would still like to get rid of TIF_MEMDIE completely but I do not have
> time to do it now and it is not a pressing issue.
> 
> [1] http://lkml.kernel.org/r/20161004090009.7974-1-mhocko@kernel.org

Are there any more comments/questions? I will resubmit if not.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
