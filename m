Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 16A9E6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:06:56 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so247569pbc.8
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 15:06:55 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so404896pab.25
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 15:06:53 -0700 (PDT)
Date: Wed, 25 Sep 2013 15:06:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always
 succeed
In-Reply-To: <20130925143009.913fb1c042abe10d91c86c8b@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1309251505330.1835@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com> <20130925031127.GA4210@redhat.com> <alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com> <20130925032530.GA4771@redhat.com>
 <alpine.DEB.2.02.1309251057080.17676@chino.kir.corp.google.com> <20130925143009.913fb1c042abe10d91c86c8b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Sep 2013, Andrew Morton wrote:

> > I fully agree and have code in the oom killer that has the "fall through" 
> > comment if there's code in between the case statements, but I think things 
> > like
> > 
> > 	case MPOL_BIND:
> > 	case MPOL_INTERLEAVE:
> > 		...
> > 
> > is quite easy to read.  I don't feel strongly at all, though, so I'll just 
> > leave it to Andrew's preference.
> 
> I've never even thought about it, but that won't prevent me from
> pretending otherwise!  How about:
> 
> This:
> 
> 	case WIBBLE:
> 		something();
> 		something_else();
> 	case WOBBLE:
> 
> needs a /* fall through */ comment (because it *looks* like a mistake),
> whereas
> 
> 	case WIBBLE:
> 	case WOBBLE:
> 
> does not?
> 

The switch-case examples given in Documentation/CodingStyle agree with 
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
