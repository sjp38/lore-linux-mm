Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id AB8436B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:56:59 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so2364279pbb.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:56:59 -0700 (PDT)
Date: Fri, 24 Aug 2012 05:56:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] revert changes to zcache_do_preload()
Message-ID: <20120823205648.GA2066@barrios>
References: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, xiaoguangrong@linux.vnet.ibm.com

Hi Seth,

On Thu, Aug 23, 2012 at 10:33:09AM -0500, Seth Jennings wrote:
> This patchset fixes a regression in 3.6 by reverting two dependent
> commits that made changes to zcache_do_preload().
> 
> The commits undermine an assumption made by tmem_put() in
> the cleancache path that preemption is disabled.  This change
> introduces a race condition that can result in the wrong page
> being returned by tmem_get(), causing assorted errors (segfaults,
> apparent file corruption, etc) in userspace.
> 
> The corruption was discussed in this thread:
> https://lkml.org/lkml/2012/8/17/494

I think changelog isn't enough to explain what's the race.
Could you write it down in detail?

And you should Cc'ed Xiao who is author of reverted patch.

> 
> Please apply this patchset to 3.6.  This problem didn't exist
> in previous releases so nothing need be done for the stable trees.
> 
> Seth Jennings (2):
>   Revert "staging: zcache: cleanup zcache_do_preload and
>     zcache_put_page"
>   Revert "staging: zcache: optimize zcache_do_preload"
> 
>  drivers/staging/zcache/zcache-main.c |   54 +++++++++++++++++++---------------
>  1 file changed, 31 insertions(+), 23 deletions(-)
> 
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
