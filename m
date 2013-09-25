Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id A6EB66B0034
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:58:32 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so11338pbc.17
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:58:32 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so9254pdj.31
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:58:29 -0700 (PDT)
Date: Wed, 25 Sep 2013 10:58:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always
 succeed
In-Reply-To: <20130925032530.GA4771@redhat.com>
Message-ID: <alpine.DEB.2.02.1309251057080.17676@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com> <20130925031127.GA4210@redhat.com> <alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com>
 <20130925032530.GA4771@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Sep 2013, Dave Jones wrote:

>  > 	/* fall through */
>  > 
>  > for all of them would be pretty annoying.
>  
> agreed, but with that example, it seems pretty obvious (to me at least)
> that the lack of break's is intentional.  Where it gets trickier to
> make quick judgment calls is cases like the one I mentioned above,
> where there are only a few cases, and there's real code involved in
> some but not all cases.
> 

I fully agree and have code in the oom killer that has the "fall through" 
comment if there's code in between the case statements, but I think things 
like

	case MPOL_BIND:
	case MPOL_INTERLEAVE:
		...

is quite easy to read.  I don't feel strongly at all, though, so I'll just 
leave it to Andrew's preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
