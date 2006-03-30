From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swsusp shrink_all_memory tweaks
Date: Fri, 31 Mar 2006 06:38:23 +1000
References: <200603200231.50666.kernel@kolivas.org> <200603241714.48909.rjw@sisk.pl> <200603301912.32204.rjw@sisk.pl>
In-Reply-To: <200603301912.32204.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603310638.23873.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 31 March 2006 03:12, Rafael J. Wysocki wrote:
> OK, I have the following observations:

Thanks.
>
> 1) The patch generally causes more memory to be freed during suspend than
> the unpatched code (good).

Yes I know you meant less, that's good.

> 2) However, if more than 50% of RAM is used by application data, it causes
> the swap prefetch to trigger during resume (that's an impression; anyway
> the system swaps in a lot at that time), which takes some time (generally
> it makes resume 5-10s longer on my box).

Is that with this "swsusp shrink_all_memory tweaks" patch alone? It doesn't 
touch swap prefetch.

> 3) The problem with returning zero prematurely has not been entirely
> eliminated.  It's happened for me only once, though.

Probably hard to say, but is the system in any better state after resume has 
completed? That was one of the aims. Also a major part of this patch is a 
cleanup of the hot balance_pgdat function as well, which suspend no longer 
touches with this patch.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
