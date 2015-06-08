Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f48.google.com (mail-vn0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 404266B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 05:39:40 -0400 (EDT)
Received: by vnbg129 with SMTP id g129so16617239vnb.9
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 02:39:40 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id if6si3894830vdb.58.2015.06.08.02.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 02:39:39 -0700 (PDT)
Date: Mon, 8 Jun 2015 04:39:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
In-Reply-To: <20150608112359.04a3750e@redhat.com>
Message-ID: <alpine.DEB.2.11.1506080438570.10781@east.gentwo.org>
References: <20150604103159.4744.75870.stgit@ivy> <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com> <20150608112359.04a3750e@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, netdev@vger.kernel.org

On Mon, 8 Jun 2015, Jesper Dangaard Brouer wrote:

> My real question is if disabling local interrupts is enough to avoid this?

Yes the initial release of slub used interrupt disable in the fast paths.

> And, does local irq disabling also stop preemption?

Of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
