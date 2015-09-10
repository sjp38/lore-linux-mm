Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id B80B36B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:36:20 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so24464547igc.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:36:20 -0700 (PDT)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id gb7si816330igd.85.2015.09.10.09.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 09:36:20 -0700 (PDT)
Date: Thu, 10 Sep 2015 11:36:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
In-Reply-To: <55F12FC1.2070801@suse.cz>
Message-ID: <alpine.DEB.2.11.1509101135590.9501@east.gentwo.org>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com> <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org> <55F12FC1.2070801@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, 10 Sep 2015, Vlastimil Babka wrote:

> > For a partial cacheline it would have to read the rest of the cacheline
> > before updating. And I would expect the processor to have exclusive access
> > to the cacheline that is held in a store buffer. If not then there is
> > trouble afoot.
>
> IIRC that (or something similar with same guarantees) basically happens on x86
> when you use the LOCK prefix, i.e. for atomic inc etc. Doing that always would
> destroy performance.

Well yes but it also happens anytime you try to write to a cacheline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
