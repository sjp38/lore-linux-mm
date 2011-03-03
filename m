Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF5BA8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:17:20 -0500 (EST)
Date: Wed, 2 Mar 2011 18:17:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2011-03-02-16-52 uploaded
Message-Id: <20110302181711.2399cdba.akpm@linux-foundation.org>
In-Reply-To: <20110303130538.3e99f952.sfr@canb.auug.org.au>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
	<20110303130538.3e99f952.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 3 Mar 2011 13:05:38 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Wed, 02 Mar 2011 16:52:55 -0800 akpm@linux-foundation.org wrote:
> >
> > The mm-of-the-moment snapshot 2011-03-02-16-52 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> If you create your linux-next.patch using kapm-start..kapm-end in the
> linux-next tree, you will save about 8000+ lines of patch and you won't
> need "next-remove-localversion.patch" any more.  I am keeping those
> references up to date each day.

What's in the 8000 lines?

> BTW, To keep "git am" happy:
> 
> diff --git a/broken-out/memcg-keep-only-one-charge-cancelling-function-fix.patch
> index e081c43..42c45fc 100644
> --- a/broken-out/memcg-keep-only-one-charge-cancelling-function-fix.patch
> +++ b/broken-out/memcg-keep-only-one-charge-cancelling-function-fix.patch
> @@ -1,3 +1,4 @@
> +From: Johannes Weiner <hannes@cmpxchg.org>
>  
>  Keep the underscore-version of the charge cancelling function which took a
>  page count, rather than silently changing the semantics of the
> 

Didn't understand that - why is git-am unhappy?  Your sentence was
truncated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
