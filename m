Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D56236B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 18:06:17 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so6827356pab.24
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:06:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zk9si16835146pac.318.2014.02.10.15.06.16
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 15:06:16 -0800 (PST)
Date: Mon, 10 Feb 2014 15:06:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zswap: add writethrough option
Message-Id: <20140210150614.c6a1b20553803da5f81acb72@linux-foundation.org>
In-Reply-To: <CALZtONAFF3F4j0KQX=ineJ1cOVEWJSGSe3V=Ja4x=3NguFAFMQ@mail.gmail.com>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
	<1390831279-5525-1-git-send-email-ddstreet@ieee.org>
	<20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
	<CALZtONAFF3F4j0KQX=ineJ1cOVEWJSGSe3V=Ja4x=3NguFAFMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Mon, 10 Feb 2014 14:05:14 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> >
> > It does sound like the feature is of marginal benefit.  Is "zswap
> > filled up" an interesting or useful case to optimize?
> >
> > otoh the addition is pretty simple and we can later withdraw the whole
> > thing without breaking anyone's systems.
> 
> ping...
> 
> you still thinking about this or is it a reject for now?

I'm not seeing a compelling case for merging it and Minchan sounded
rather unconvinced.  Perhaps we should park it until/unless a more
solid need is found?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
