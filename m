Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 39BC96B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 16:53:59 -0400 (EDT)
Received: by weys10 with SMTP id s10so5884202wey.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:53:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
Date: Tue, 31 Jul 2012 23:53:57 +0300
Message-ID: <CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
Subject: Re: [RFC/PATCH] zcache/ramster rewrite and promotion
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 31, 2012 at 11:18 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> diffstat vs 3.5:
>  drivers/staging/ramster/Kconfig       |    2
>  drivers/staging/ramster/Makefile      |    2
>  drivers/staging/zcache/Kconfig        |    2
>  drivers/staging/zcache/Makefile       |    2
>  mm/Kconfig                            |    2
>  mm/Makefile                           |    4
>  mm/tmem/Kconfig                       |   33
>  mm/tmem/Makefile                      |    5
>  mm/tmem/tmem.c                        |  894 +++++++++++++
>  mm/tmem/tmem.h                        |  259 +++
>  mm/tmem/zbud.c                        | 1060 +++++++++++++++
>  mm/tmem/zbud.h                        |   33
>  mm/tmem/zcache-main.c                 | 1686 +++++++++++++++++++++++++
>  mm/tmem/zcache.h                      |   53
>  mm/tmem/ramster.h                     |   59
>  mm/tmem/ramster/heartbeat.c           |  462 ++++++
>  mm/tmem/ramster/heartbeat.h           |   87 +
>  mm/tmem/ramster/masklog.c             |  155 ++
>  mm/tmem/ramster/masklog.h             |  220 +++
>  mm/tmem/ramster/nodemanager.c         |  995 +++++++++++++++
>  mm/tmem/ramster/nodemanager.h         |   88 +
>  mm/tmem/ramster/r2net.c               |  414 ++++++
>  mm/tmem/ramster/ramster.c             |  985 ++++++++++++++
>  mm/tmem/ramster/ramster.h             |  161 ++
>  mm/tmem/ramster/ramster_nodemanager.h |   39
>  mm/tmem/ramster/tcp.c                 | 2253 ++++++++++++++++++++++++++++++++++
>  mm/tmem/ramster/tcp.h                 |  159 ++
>  mm/tmem/ramster/tcp_internal.h        |  248 +++
> 28 files changed, 10358 insertions(+), 4 deletions(-)

So it's basically this commit, right?

https://oss.oracle.com/git/djm/tmem.git/?p=djm/tmem.git;a=commitdiff;h=22844fe3f52d912247212408294be330a867937c

Why on earth would you want to move that under the mm directory?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
