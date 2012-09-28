Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 337456B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 16:36:19 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so6280374pbb.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:36:18 -0700 (PDT)
Date: Fri, 28 Sep 2012 13:36:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a0d314c3f-e5b12d01-7a99-4368-82a0-f5de4d46f804-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209281332460.21335@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <0000013a08020b4d-ecc22fc9-75e4-4f1d-8a76-5496a98d1df9-000000@email.amazonses.com> <alpine.DEB.2.00.1209271546460.13360@chino.kir.corp.google.com>
 <0000013a0d314c3f-e5b12d01-7a99-4368-82a0-f5de4d46f804-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, Christoph Lameter wrote:

> > > This means touching another field from critical paths of the allocators.
> > > It would increase the cache footprint and therefore reduce performance.
> > >
> >
> > To clarify your statement, you're referring to the mm/slab.c allocation of
> > new slab pages and when debugging is enabled as "critical paths", correct?
> > We would disagree on that point.
> 
> This is not debugging specific. Flags are also consulted to do RCU
> processing and other things.
> 

There is no "critical path" in mm/slab.c that tests CFLGS_OFF_SLAB; the 
flag itself is used to determine where slab management is done and you 
certainly wouldn't want to find this for any path that is critical.

If you'd like to disagree with that, please show the code and why you 
consider increasing the cache footprint in that case to be critical to 
performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
