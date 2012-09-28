Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8082E6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:04:27 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:04:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209271546460.13360@chino.kir.corp.google.com>
Message-ID: <0000013a0d314c3f-e5b12d01-7a99-4368-82a0-f5de4d46f804-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <0000013a08020b4d-ecc22fc9-75e4-4f1d-8a76-5496a98d1df9-000000@email.amazonses.com> <alpine.DEB.2.00.1209271546460.13360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, David Rientjes wrote:

> > This means touching another field from critical paths of the allocators.
> > It would increase the cache footprint and therefore reduce performance.
> >
>
> To clarify your statement, you're referring to the mm/slab.c allocation of
> new slab pages and when debugging is enabled as "critical paths", correct?
> We would disagree on that point.

This is not debugging specific. Flags are also consulted to do RCU
processing and other things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
