Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id CDADE6B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 04:23:22 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so1608285eaa.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 01:23:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351840367-4152-4-git-send-email-minchan@kernel.org>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
	<1351840367-4152-4-git-send-email-minchan@kernel.org>
Date: Fri, 2 Nov 2012 10:23:21 +0200
Message-ID: <CAOJsxLFfH4R+mVtCgQB2xpRPBZerZLKLq5UNM0k2+2U5YyzRPw@mail.gmail.com>
Subject: Re: [PATCH v4 3/3] zram: select ZSMALLOC when ZRAM is configured
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, gaowanlong@cn.fujitsu.com

On Fri, Nov 2, 2012 at 9:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> At the monent, we can configure zram in driver/block once zsmalloc
> in /lib menu is configured firstly. It's not convenient.
>
> User can configure zram in driver/block regardless of zsmalloc enabling
> by this patch.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
