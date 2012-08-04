Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A87EC6B005D
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 04:57:29 -0400 (EDT)
Received: by weys10 with SMTP id s10so1173437wey.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 01:57:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120731210438.GA31713@phenom.dumpdata.com>
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
	<CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
	<20120731210438.GA31713@phenom.dumpdata.com>
Date: Sat, 4 Aug 2012 11:57:27 +0300
Message-ID: <CAOJsxLEsDTp+ZkhVNDSreD3DhsS+D88MpMJFEzYmu+Eg8GcBYA@mail.gmail.com>
Subject: Re: [RFC/PATCH] zcache/ramster rewrite and promotion
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Konrad,

> On Tue, Jul 31, 2012 at 11:53:57PM +0300, Pekka Enberg wrote:
>> Why on earth would you want to move that under the mm directory?

On Wed, Aug 1, 2012 at 12:04 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> If you take aside that problem that it is one big patch instead
> of being split up in more reasonable pieces - would you recommend
> that it reside in a different directory?
>
> Or is that it does not make sense b/c it has other components in it - such
> as tcp/nodemaneger/hearbeat/etc so it should go under the refactor knife?
>
> And if you rip out the ramster from this and just concentrate on zcache -
> should that go in drivers/mm or mm/tmem/zcache?

I definitely think mm/zcache.c makes sense. I hate the fact that it's
now riddled with references to "tmem" and "ramster" but that's probably
fixable. I also hate the fact that you've now gone and rewritten
everything so we lose all the change history zcache has had under
staging.

As for ramster, it might make sense to have its core in mm/ramster.c and
move the TCP weirdness somewhere else. The exact location depends on
what kind of userspace ABIs you expose, I suppose. I mean, surely you
need to configure the thing somehow?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
