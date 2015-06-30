Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 743EC6B006E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 19:49:28 -0400 (EDT)
Received: by igrv9 with SMTP id v9so23697513igr.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 16:49:27 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id zx8si47061igc.15.2015.06.30.16.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 16:49:27 -0700 (PDT)
Received: by ieqy10 with SMTP id y10so23703543ieq.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 16:49:27 -0700 (PDT)
Date: Tue, 30 Jun 2015 16:49:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
In-Reply-To: <20150618154716.GH5858@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506301646500.5359@chino.kir.corp.google.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com> <557AA834.8070503@suse.cz> <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com> <20150618143019.GE5858@dhcp22.suse.cz> <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
 <20150618144311.GF5858@dhcp22.suse.cz> <5582E240.8080704@suse.cz> <20150618154716.GH5858@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, Eric Dumazet <edumazet@google.com>, Shaohua Li <shli@fb.com>, netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com

On Thu, 18 Jun 2015, Michal Hocko wrote:

> That is to be discussed. Most allocations already express their interest
> in memory reserves by __GFP_HIGH directly or by GFP_ATOMIC indirectly.
> So maybe we do not need any additional flag here. There are not that
> many ~__GFP_WAIT and most of them seem to require it _only_ because the
> context doesn't allow for sleeping (e.g. to prevent from deadlocks).
> 

We're talking about a patch that is being backported to stable.  
Regardless of what improvements can be made to specify that an allocation 
shouldn't be able to access reserves (and what belongs solely in the page 
allocator proper) independent of __GFP_NO_KSWAPD, that can be cleaned up 
at a later time.  I don't anticipate that cleanup to be backported to 
stable, and my primary concern here is the ability for this allocations to 
now access, and possibly deplete, memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
