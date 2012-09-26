Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id F1AC56B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 13:06:13 -0400 (EDT)
Received: by vcbfl17 with SMTP id fl17so1227022vcb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 10:06:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
	<1348649419-16494-2-git-send-email-minchan@kernel.org>
	<CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
Date: Wed, 26 Sep 2012 10:06:12 -0700
Message-ID: <CAPkvG_eB84ELG_r_dVGvS+G7i21+8wqXon8a1Hfgctqsf4=BKw@mail.gmail.com>
Subject: Re: [PATCH 1/3] zsmalloc: promote to lib/
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

2012/9/26 Pekka Enberg <penberg@kernel.org>:
> On Wed, Sep 26, 2012 at 11:50 AM, Minchan Kim <minchan@kernel.org> wrote:
>>  lib/Kconfig                              |    2 +
>>  lib/Makefile                             |    1 +
>>  lib/zsmalloc/Kconfig                     |   18 +
>>  lib/zsmalloc/Makefile                    |    1 +
>>  lib/zsmalloc/zsmalloc.c                  | 1064 ++++++++++++++++++++++++++++++
>
> What's wrong with mm/zsmalloc.c?

I think mm/ directory should only contain the code which is intended
for global use such as the slab allocator, page reclaim code etc.
zsmalloc is used by only one (or possibly two) drivers, so lib/ seems
to be the right place.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
