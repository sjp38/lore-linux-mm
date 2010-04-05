Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29329600337
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:19:43 -0400 (EDT)
Date: Mon, 5 Apr 2010 13:19:31 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100405111930.GE23515@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop> <20100404195533.GA8836@logfs.org> <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com> <20100405053026.GA23515@logfs.org> <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com> <20100405071344.GC23515@logfs.org> <m2w28c262361004050126mbcbed77cha6f1085394802cb2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <m2w28c262361004050126mbcbed77cha6f1085394802cb2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 April 2010 17:26:58 +0900, Minchan Kim wrote:
> 
> Seem to be not bad idea. :)
> But we have to justify new interface before. For doing it, we have to say
> why we can't do it by current functions(find_get_page,
> add_to_page_cache and pagevec_lru_add_xxx)

I guess we could do that.  Whether setting up a vector when only dealing
with single pages makes the code more readable or helps performance is a
different matter, though.

> Pagevec_lru_add_xxx does batch so that it can reduce calling path and
> some overhead(ex, page_is_file_cache comparison,
> get/put_cpu_var(lru_add_pvecs)).
> 
> At least, it would be rather good than old for performance.

...if we can convert callers to also handle vectors.  And if backing
device is fast enough that cpu overhead becomes noticeable.  And if
there were no bigger fish left to catch.

JA?rn

-- 
Joern's library part 15:
http://www.knosof.co.uk/cbook/accu06a.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
