Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 64A216B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:34:11 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so29320271pac.3
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 02:34:11 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ol11si27581457pab.5.2015.07.13.02.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 02:34:10 -0700 (PDT)
Received: by padck2 with SMTP id ck2so39993677pad.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 02:34:10 -0700 (PDT)
Date: Mon, 13 Jul 2015 18:34:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150713092531.GA578@swordfish>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
 <20150712024732.GA787@swordfish>
 <20150713063341.GA24167@infradead.org>
 <20150713065253.GA811@swordfish>
 <20150713090358.GA28901@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713090358.GA28901@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/13/15 02:03), Christoph Hellwig wrote:
> On Mon, Jul 13, 2015 at 03:52:53PM +0900, Sergey Senozhatsky wrote:
> > Why? In some sense, shrinker callbacks are just a way to be nice.
> > No one writes a driver just to be able to handle shrinker calls. An
> > ability to react to those calls is just additional option; it does
> > not directly affect or limit driver's functionality (at least, it
> > really should not).
> 
> No, they are not just nice.  They are a fundamental part of memory
> management and required to reclaim (often large) amounts of memory.

Yes. 'Nice' used in a sense that drivers have logic to release the
memory anyway; mm asks volunteers (the drivers that have registered
shrinker callbacks) to release some spare/wasted/etc. when things
are getting tough (the drivers are not aware of that in general).
This is surely important to mm, not to the driver though -- it just
agrees to be 'nice', but even not expected to release any memory at
all (IOW, this is not a contract).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
