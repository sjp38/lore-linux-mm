Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A984D6B0062
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 13:13:57 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so1636707wib.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 10:13:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ad942d93-489f-4bf4-96bc-8f65b1a23ea1@default>
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
	<CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
	<b9bee363-321e-409a-bc8e-65ffed8a1dc5@default>
	<CAOJsxLHe6egmMWdEAGj7DGHHX-hqYMhVWDggny9CsT0H-DOL-g@mail.gmail.com>
	<f54214e7-cee4-4cbf-aad1-6c1f91867879@default>
	<CAOJsxLHyPj6KrVkB5nj-9vFBXKmn5BN4ArN_7MDmTeVEG3N3Gw@mail.gmail.com>
	<ad942d93-489f-4bf4-96bc-8f65b1a23ea1@default>
Date: Mon, 6 Aug 2012 20:13:55 +0300
Message-ID: <CAOJsxLHwFqjFC8BqfCHA_6OPFbvNfaFkQEjfPTw=_6QsPKweNw@mail.gmail.com>
Subject: Re: [RFC/PATCH] zcache/ramster rewrite and promotion
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 6, 2012 at 7:10 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> Hmmm.. there's also zbud.c and tmem.c which are critical components
> of both zcache and ramster.  And there are header files as well which
> will need to either be in mm/ or somewhere in include/linux/
>
> Is there a reason or rule that mm/ can't have subdirectories?
>
> Since zcache has at least three .c files plus ramster.c, and
> since mm/frontswap.c and mm/cleancache.c are the foundation on
> which all of these are built, I was thinking grouping all six
> (plus headers) in the same mm/tmem/ subdirectory was a good
> way to keep mm/ from continuing to get more cluttered... not counting
> new zcache and ramster files, there are now 74 .c files in mm/!
> (Personally, I think a directory has too many files in it if
> "ls" doesn't fit in a 25x80 window.)
>
> Thoughts?

There's no reason we can't have subdirectories. That said, I really
don't see the point of having a separate directory called 'tmem'. It
might make sense to have mm/zcache and/or mm/ramster but I suspect
you can just fold the core code in mm/zcache.c and mm/ramster.c by
slimming down the weird Solaris-like 'tmem' abstractions.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
