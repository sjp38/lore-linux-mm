Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6435A6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:05:38 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r3so9816134wrb.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:05:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 50si15417679wrx.3.2017.05.22.23.05.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 23:05:37 -0700 (PDT)
Date: Tue, 23 May 2017 08:05:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170523060534.GA12813@dhcp22.suse.cz>
References: <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522150321.GM8509@dhcp22.suse.cz>
 <20170522180415.GA25340@redhat.com>
 <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Junaid Shahid <junaids@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon 22-05-17 13:35:41, David Rientjes wrote:
> On Mon, 22 May 2017, Mike Snitzer wrote:
[...]
> > While adding the __GFP_NOFAIL flag would serve to document expectations
> > I'm left unconvinced that the memory allocator will _not fail_ for an
> > order-0 page -- as Mikulas said most ioctls don't need more than 4K.
> 
> __GFP_NOFAIL would make no sense in kvmalloc() calls, ever, it would never 
> fallback to vmalloc :)

Sorry, I could have been more specific. You would have to opencode
kvmalloc obviously. It is documented to not support this flag for the
reasons you have mentioned above.

> I'm hoping this can get merged during the 4.12 window to fix the broken 
> commit d224e9381897.

I obviously disagree. Relying on memory reserves for _correctness_ is
clearly broken by design, full stop. But it is dm code and you are going
it is responsibility of the respective maintainers to support this code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
