From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH][3/3] mm: swsusp post resume aggressive swap prefetch
Date: Mon, 20 Mar 2006 22:47:37 +0100
References: <200603200234.01472.kernel@kolivas.org>
In-Reply-To: <200603200234.01472.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603202247.38576.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sunday 19 March 2006 16:34, Con Kolivas wrote:
> 
> Swsusp reclaims a lot of memory during the suspend cycle and can benefit
> from the aggressive_swap_prefetch mode immediately upon resuming.

It slows down the resume on my box way too much.  Last time it took 10x more
time than actually reading the image.

I think the problem is for the userland suspend (which I use) it's done too early,
when the image pages are still in the swap, so they are taken into consideration
by the aggressive prefetch.  If that really is the case, the solution would be to
trigger the aggressive prefetch from the userland, if needed, after the image
pages have been released.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
