Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 9BC876B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 11:47:56 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so2758500wgb.26
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 08:47:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <041cb4ce-48ae-4600-9f11-d722bc03b9cc@default>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
	<20120727205932.GA12650@localhost.localdomain>
	<d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
	<5016DE4E.5050300@linux.vnet.ibm.com>
	<f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
	<20120731155843.GP4789@phenom.dumpdata.com>
	<20120731161916.GA4941@kroah.com>
	<20120731175142.GE29533@phenom.dumpdata.com>
	<20120806003816.GA11375@bbox>
	<041cb4ce-48ae-4600-9f11-d722bc03b9cc@default>
Date: Mon, 6 Aug 2012 18:47:54 +0300
Message-ID: <CAOJsxLHDcgxxu146QWXw0ZhMHMhFOquEFXhF55HK2mCjHzk7hw@mail.gmail.com>
Subject: Re: [PATCH 0/4] promote zcache from staging
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Aug 6, 2012 at 6:24 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> IMHO, the fastest way to get the best zcache into the kernel and
> to distros and users is to throw away the "demo" version, move forward
> to a new solid well-designed zcache code base, and work together to
> build on it.  There's still a lot to do so I hope we can work together.

I'm not convinced it's the _fastest way_. You're effectively
invalidating all the work done under drivers/staging so you might end up
in review limbo with your shiny new code...

AFAICT, your best bet is to first clean up zcache under driver/staging
and get that promoted under mm/zcache.c. You can then move on to the
more controversial ramster and figure out where to put the clustering
code, etc.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
