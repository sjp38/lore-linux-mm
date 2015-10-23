Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 86B556B0254
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 12:10:41 -0400 (EDT)
Received: by igbdj2 with SMTP id dj2so18881308igb.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:10:41 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id j139si16395280ioj.46.2015.10.23.09.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Oct 2015 09:10:40 -0700 (PDT)
Date: Fri, 23 Oct 2015 11:10:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Make vmstat deferrable again (was Re: [PATCH] mm,vmscan: Use
 accurate values for zone_reclaimable() checks)
In-Reply-To: <20151023144928.GA455@swordfish>
Message-ID: <alpine.DEB.2.20.1510231109510.14715@east.gentwo.org>
References: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org> <20151022140944.GA30579@mtj.duckdns.org> <20151022150623.GE26854@dhcp22.suse.cz> <20151022151528.GG30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510221031090.24250@east.gentwo.org> <20151023083719.GD2410@dhcp22.suse.cz> <alpine.DEB.2.20.1510230642210.5612@east.gentwo.org> <20151023120728.GA462@swordfish> <alpine.DEB.2.20.1510230910370.12801@east.gentwo.org>
 <20151023144928.GA455@swordfish>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri, 23 Oct 2015, Sergey Senozhatsky wrote:

> by the way, tick_nohz_stop_sched_tick() receives cpu from __tick_nohz_idle_enter().
> do you want to pass it to quiet_vmstat()?

No this is quite wrong at this point. quiet_vmstat() needs to be called
from the cpu going into idle state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
