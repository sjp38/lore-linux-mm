Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0C95C6B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:35:56 -0400 (EDT)
Received: by wiga1 with SMTP id a1so173405956wig.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:35:55 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id d8si4880599wic.1.2015.06.18.07.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 07:35:54 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so25043184wiw.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:35:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150618143019.GE5858@dhcp22.suse.cz>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
	<557AA834.8070503@suse.cz>
	<alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
	<20150618143019.GE5858@dhcp22.suse.cz>
Date: Thu, 18 Jun 2015 07:35:53 -0700
Message-ID: <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
From: Eric Dumazet <edumazet@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Shaohua Li <shli@fb.com>, netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com

On Thu, Jun 18, 2015 at 7:30 AM, Michal Hocko <mhocko@suse.cz> wrote:

> Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
> _current_ implementation of the allocator has this nasty and very subtle
> side effect but that doesn't mean it should be abused outside of the mm
> proper. Why shouldn't this path wake the kswapd and let it compact
> memory on the background to increase the success rate for the later
> high order allocations?

I kind of agree.

If kswapd is a problem (is it ???) we should fix it, instead of adding
yet another flag to some random locations attempting
memory allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
