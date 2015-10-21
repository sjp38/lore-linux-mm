Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id ED7CC82F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:49:09 -0400 (EDT)
Received: by qkca6 with SMTP id a6so37436071qkc.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:49:09 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id o2si8271055qki.111.2015.10.21.07.49.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 07:49:09 -0700 (PDT)
Date: Wed, 21 Oct 2015 09:49:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151021143337.GD8805@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Wed, 21 Oct 2015, Michal Hocko wrote:

> Because all the WQ workers are stuck somewhere, maybe in the memory
> allocation which cannot make any progress and the vmstat update work is
> queued behind them.
>
> At least this is my current understanding.

Eww. Maybe need a queue that does not do such evil things as memory
allocation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
