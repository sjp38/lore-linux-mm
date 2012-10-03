Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B27E36B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 01:00:22 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so6931432pad.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 22:00:21 -0700 (PDT)
Date: Tue, 2 Oct 2012 22:00:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] make GFP_NOTRACK flag unconditional
In-Reply-To: <1348826194-21781-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210022156450.8723@chino.kir.corp.google.com>
References: <1348826194-21781-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> There was a general sentiment in a recent discussion (See
> https://lkml.org/lkml/2012/9/18/258) that the __GFP flags should be
> defined unconditionally. Currently, the only offender is GFP_NOTRACK,
> which is conditional to KMEMCHECK.
> 
> This simple patch makes it unconditional.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

I think it was done this way to show that if CONFIG_KMEMCHECK=n then the 
bit could be reused for something else but I can't think of any reason why 
that would be useful; what would need to add a gfp bit that would also 
happen to depend on CONFIG_KMEMCHECK=n?  Nothing comes to mind to save a 
bit.

There are other cases of this as well, like __GFP_OTHER_NODE which is only 
useful for thp and it's defined unconditionally.  So this seems fine to 
me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
