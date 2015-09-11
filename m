Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id DDD036B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 10:49:33 -0400 (EDT)
Received: by qgez77 with SMTP id z77so64412424qge.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:49:33 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id k18si608144qkl.20.2015.09.11.07.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 11 Sep 2015 07:49:33 -0700 (PDT)
Date: Fri, 11 Sep 2015 09:49:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab:Fix the unexpected index mapping result of kmalloc_size(INDEX_NODE
 + 1)
In-Reply-To: <CAAmzW4O9d6i1cDArzG72WpBQfn5VgmiQVr1DBS8QN4o4V7gPHg@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509110949200.16555@east.gentwo.org>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn> <20150729152803.67f593847050419a8696fe28@linux-foundation.org> <20150731001827.GA15029@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
 <20150807015609.GB15802@js1304-P5Q-DELUXE> <20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org> <20150907053855.GC21207@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1509081249240.26204@east.gentwo.org>
 <CAAmzW4O9d6i1cDArzG72WpBQfn5VgmiQVr1DBS8QN4o4V7gPHg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Fri, 11 Sep 2015, Joonsoo Kim wrote:

> So, when we initialize 96, 192 or 8, proper slab isn't initialized.
> If we allow debug_pagealloc larger than 256 sized slab,
> small sized slab would be already initialized so no error
> happens. I think it is better than
> kmalloc_size(INDEX_NODE) * 2, because that doesn't
> guarantee size is larger than 192.

Sounds good. Please send a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
