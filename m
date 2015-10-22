Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6359682F66
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:33:22 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so16399197igb.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:33:22 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id t5si1635009igd.80.2015.10.22.08.33.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 08:33:21 -0700 (PDT)
Date: Thu, 22 Oct 2015 10:33:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151022151528.GG30579@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510221031090.24250@east.gentwo.org>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org> <20151021143337.GD8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org> <20151022140944.GA30579@mtj.duckdns.org> <20151022150623.GE26854@dhcp22.suse.cz> <20151022151528.GG30579@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Ok that also makes me rethink commit
ba4877b9ca51f80b5d30f304a46762f0509e1635 which seems to be a similar fix
this time related to idle mode not updating the counters.

Could we fix that by folding the counters before going to idle mode?

That fix seems to now create 2 separate application interuptions because
the vmstat update is not deferred anymore to occur with other events.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
