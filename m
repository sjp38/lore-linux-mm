Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E0AA26B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 05:51:50 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so378900wib.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 02:51:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348649419-16494-2-git-send-email-minchan@kernel.org>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
	<1348649419-16494-2-git-send-email-minchan@kernel.org>
Date: Wed, 26 Sep 2012 12:51:49 +0300
Message-ID: <CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
Subject: Re: [PATCH 1/3] zsmalloc: promote to lib/
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Sep 26, 2012 at 11:50 AM, Minchan Kim <minchan@kernel.org> wrote:
>  lib/Kconfig                              |    2 +
>  lib/Makefile                             |    1 +
>  lib/zsmalloc/Kconfig                     |   18 +
>  lib/zsmalloc/Makefile                    |    1 +
>  lib/zsmalloc/zsmalloc.c                  | 1064 ++++++++++++++++++++++++++++++

What's wrong with mm/zsmalloc.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
