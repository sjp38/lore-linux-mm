Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC9F6B025E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 08:26:51 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id w185so50869610vkf.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:26:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p4si30308710qkd.70.2016.06.01.05.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 05:26:50 -0700 (PDT)
Date: Wed, 1 Jun 2016 08:26:47 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: The patch "mm, page_alloc: avoid looking up the first zone in
 a zonelist twice" breaks memory management
In-Reply-To: <574E0687.5050201@suse.cz>
Message-ID: <alpine.LRH.2.02.1606010817550.6561@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1605311706040.16635@file01.intranet.prod.int.rdu2.redhat.com> <574E0687.5050201@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Helge Deller <deller@gmx.de>



On Tue, 31 May 2016, Vlastimil Babka wrote:

> On 05/31/2016 11:20 PM, Mikulas Patocka wrote:
> > Hi
> > 
> > The patch c33d6c06f60f710f0305ae792773e1c2560e1e51 ("mm, page_alloc: avoid 
> > looking up the first zone in a zonelist twice") breaks memory management 
> > on PA-RISC.
> 
> Hi,
> 
> I think the linked patch should help. Please try and report.
> 
> http://marc.info/?i=20160531100848.GR2527%40techsingularity.net
> 
> Thanks,
> Vlastimil

Thanks, that patch fixes it.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
