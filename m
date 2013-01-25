Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BEA2D6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 19:11:20 -0500 (EST)
Received: by mail-ia0-f173.google.com with SMTP id l29so5694176iag.4
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 16:11:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357590280-31535-4-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1357590280-31535-4-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Thu, 24 Jan 2013 16:11:19 -0800
Message-ID: <CAPkvG_fFoc3ExetwxwN-vNMOOmkWgCYmh+shj3wFvjYB5i6YsQ@mail.gmail.com>
Subject: Re: [PATCHv2 3/9] staging: zsmalloc: add page alloc/free callbacks
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jan 7, 2013 at 12:24 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> This patch allows users of zsmalloc to register the
> allocation and free routines used by zsmalloc to obtain
> more pages for the memory pool.  This allows the user
> more control over zsmalloc pool policy and behavior.
>
> If the user does not wish to control this, alloc_page() and
> __free_page() are used by default.
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c     |    2 +-
>  drivers/staging/zram/zram_drv.c          |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   43 ++++++++++++++++++++++--------
>  drivers/staging/zsmalloc/zsmalloc.h      |    8 +++++-
>  4 files changed, 41 insertions(+), 14 deletions(-)
>

Some documentation about zs_ops in zs_create_pool() would be useful.
Otherwise, looks good to me.

Acked-by: Nitin Gupta <ngupta@vflare.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
