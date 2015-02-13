Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id BF64B6B0073
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 10:49:25 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id v10so13007513qac.6
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 07:49:25 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net ([2001:558:fe21:29:250:56ff:feaf:3c65])
        by mx.google.com with ESMTPS id o65si355388qhb.19.2015.02.13.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 07:49:25 -0800 (PST)
Date: Fri, 13 Feb 2015 09:49:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
In-Reply-To: <20150213024515.GB6592@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1502130948120.9442@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.902155759@linux.com> <20150213024515.GB6592@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, 13 Feb 2015, Joonsoo Kim wrote:

> > +			*p++ = freelist;
> > +			freelist = get_freepointer(s, freelist);
> > +			allocated++;
> > +		}
>
> Fetching all objects with holding node lock could result in enomourous
> lock contention. How about getting free ojbect pointer without holding
> the node lock? We can temporarilly store all head of freelists in
> array p and can fetch each object pointer without holding node lock.


Could do that but lets first see if there is really an issue. The other
cpu sharing the same partial lists presumaly have cpu local objects to get
through first before they hit this lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
