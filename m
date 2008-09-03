Message-ID: <48BEFAF9.3030006@linux-foundation.org>
Date: Wed, 03 Sep 2008 16:00:41 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation
 by the reclaimer
References: <1220467452-15794-5-git-send-email-apw@shadowen.org> <1220475206-23684-1-git-send-email-apw@shadowen.org>
In-Reply-To: <1220475206-23684-1-git-send-email-apw@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:

>  
>  #ifndef __GENERATING_BOUNDS_H
> @@ -208,6 +211,9 @@ __PAGEFLAG(SlubDebug, slub_debug)
>   */
>  TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
>  __PAGEFLAG(Buddy, buddy)
> +PAGEFLAG(BuddyCapture, buddy_capture)	/* A buddy page, but reserved. */
> +	__SETPAGEFLAG(BuddyCapture, buddy_capture)
> +	__CLEARPAGEFLAG(BuddyCapture, buddy_capture)

Doesnt __PAGEFLAG do what you want without having to explicitly specify
__SET/__CLEAR?


How does page allocator fastpath behavior fare with this pathch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
