Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 067D982F64
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 09:39:14 -0400 (EDT)
Received: by qkfm62 with SMTP id m62so53378420qkf.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:39:13 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id d139si13261668qhc.110.2015.10.22.06.39.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 06:39:13 -0700 (PDT)
Date: Thu, 22 Oct 2015 08:39:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, 22 Oct 2015, Tetsuo Handa wrote:

> The problem would be that the "struct task_struct" to execute vmstat_update
> job does not exist, and will not be able to create one on demand because we
> are stuck at __GFP_WAIT allocation. Therefore adding a dedicated kernel
> thread for vmstat_update job would work. But ...

Yuck. Can someone please get this major screwup out of the work queue
subsystem? Tejun?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
