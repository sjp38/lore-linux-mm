Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id BEB834403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 04:06:32 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id hb3so9626919igb.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 01:06:32 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id x39si12202604ioi.207.2016.02.05.01.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 01:06:31 -0800 (PST)
Date: Fri, 5 Feb 2016 03:06:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: support left red zone
In-Reply-To: <20160204062140.GB14877@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1602050300130.13917@east.gentwo.org>
References: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com> <20160204062140.GB14877@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 4 Feb 2016, Joonsoo Kim wrote:

> On Thu, Feb 04, 2016 at 03:15:50PM +0900, Joonsoo Kim wrote:
> > SLUB already has red zone debugging feature. But, it is only positioned
> > at the end of object(aka right red zone) so it cannot catch left oob.
> > Although current object's right red zone acts as left red zone of
> > previous object, first object in a slab cannot take advantage of
>
> Oops... s/previous/next.
>
> > this effect. This patch explicitly add left red zone to each objects
> > to detect left oob more precisely.


An access before the first object is an access outside of the page
boundaries of a page allocated by the page allocator for the slab
allocator since the first object starts at offset 0.



And the page allocator debugging methods can catch that case.


Do we really need this code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
