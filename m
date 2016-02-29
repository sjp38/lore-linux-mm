Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB336B025B
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 04:39:21 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so40033301wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:39:21 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id la7si31264138wjc.203.2016.02.29.01.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 01:39:20 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [RFC] mm/page_ref, crypto/async_pq: don't put_page from __exit
Date: Mon, 29 Feb 2016 10:32:39 +0100
Message-ID: <2604022.UWS8hJ6Ygv@wuerfel>
In-Reply-To: <CAAmzW4N0YJc_O9ArC8e7Q5y4rmbHjj6-Q1yfvZ5LvORvG764cg@mail.gmail.com>
References: <1456696663-2340682-1-git-send-email-arnd@arndb.de> <CAAmzW4N0YJc_O9ArC8e7Q5y4rmbHjj6-Q1yfvZ5LvORvG764cg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Joonsoo Kim <js1304@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, Dan Williams <dan.j.williams@intel.com>, LKML <linux-kernel@vger.kernel.org>, Steven Rostedt <rostedt@goodmis.org>, "David S. Miller" <davem@davemloft.net>, Linux Memory Management List <linux-mm@kvack.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-crypto@vger.kernel.org

On Monday 29 February 2016 16:40:02 Joonsoo Kim wrote:
> 
> Hello, Arnd.
> 
> I think that we can avoid this error by using __free_page().
> It would not be inlined so calling it would have no problem.
> 
> Could you test it, please?

Yes, I suspect the driver should have done that anyway, new patch
under way.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
