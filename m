Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3BFD16B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 04:22:47 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2137898eek.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 01:22:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351840367-4152-2-git-send-email-minchan@kernel.org>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
	<1351840367-4152-2-git-send-email-minchan@kernel.org>
Date: Fri, 2 Nov 2012 10:22:45 +0200
Message-ID: <CAOJsxLEHDAj2R13riRY6TkR3sk9=o3mRigT4dQes0FZOcO2KLw@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] zsmalloc: promote to lib/
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, gaowanlong@cn.fujitsu.com

On Fri, Nov 2, 2012 at 9:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> This patch promotes the slab-based zsmalloc memory allocator
> from the staging tree to lib/
>
> zcache/zram depends on this allocator for storing compressed RAM pages
> in an efficient way under system wide memory pressure where
> high-order (greater than 0) page allocation are very likely to
> fail.
>
> For more information on zsmalloc and its internals, read the
> documentation at the top of the zsmalloc.c file.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
