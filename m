Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 58F4E6B0256
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:06:22 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so23012648igb.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 13:06:22 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id op7si3963756igb.80.2015.10.20.13.06.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 20 Oct 2015 13:06:21 -0700 (PDT)
Date: Tue, 20 Oct 2015 15:06:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: initialize kmem_cache pointer to NULL
In-Reply-To: <20151020220411.GA19775@gmail.com>
Message-ID: <alpine.DEB.2.20.1510201506060.30214@east.gentwo.org>
References: <20151020220411.GA19775@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Oct 2015, Alexandru Moise wrote:

> The assignment to NULL within the error condition was written
> in a 2014 patch to suppress a compiler warning.
> However it would be cleaner to just initialize the kmem_cache
> to NULL and just return it in case of an error condition.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
