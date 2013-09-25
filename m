Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 79A736B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 17:30:17 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so225789pdi.19
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 14:30:17 -0700 (PDT)
Date: Wed, 25 Sep 2013 14:30:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always
 succeed
Message-Id: <20130925143009.913fb1c042abe10d91c86c8b@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1309251057080.17676@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com>
	<5227CF48.5080700@asianux.com>
	<alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com>
	<20130925031127.GA4210@redhat.com>
	<alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com>
	<20130925032530.GA4771@redhat.com>
	<alpine.DEB.2.02.1309251057080.17676@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Sep 2013 10:58:27 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Tue, 24 Sep 2013, Dave Jones wrote:
> 
> >  > 	/* fall through */
> >  > 
> >  > for all of them would be pretty annoying.
> >  
> > agreed, but with that example, it seems pretty obvious (to me at least)
> > that the lack of break's is intentional.  Where it gets trickier to
> > make quick judgment calls is cases like the one I mentioned above,
> > where there are only a few cases, and there's real code involved in
> > some but not all cases.
> > 
> 
> I fully agree and have code in the oom killer that has the "fall through" 
> comment if there's code in between the case statements, but I think things 
> like
> 
> 	case MPOL_BIND:
> 	case MPOL_INTERLEAVE:
> 		...
> 
> is quite easy to read.  I don't feel strongly at all, though, so I'll just 
> leave it to Andrew's preference.

I've never even thought about it, but that won't prevent me from
pretending otherwise!  How about:

This:

	case WIBBLE:
		something();
		something_else();
	case WOBBLE:

needs a /* fall through */ comment (because it *looks* like a mistake),
whereas

	case WIBBLE:
	case WOBBLE:

does not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
