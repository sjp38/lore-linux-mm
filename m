Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DABBA6B0036
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 11:14:52 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id y10so3249227wgg.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 08:14:51 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1364870780-16296-6-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com> <1364870780-16296-6-git-send-email-liwanp@linux.vnet.ibm.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Tue, 2 Apr 2013 11:14:31 -0400
Message-ID: <CAPbh3rvRAJaQ0wfxKYkOOuKtoD+U+7WaA2shKvhTyfLB=5k2aw@mail.gmail.com>
Subject: Re: [PATCH v5 5/8] staging: zcache: fix zcache writeback in debugfs
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Apr 1, 2013 at 10:46 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> commit 9c0ad59ef ("zcache/debug: Use an array to initialize/use debugfs attributes")
> use an array to initialize/use debugfs attributes, .name = #x, .val = &zcache_##x.
> For zcache writeback, this commit set .name = zcache_outstanding_writeback_pages and
> .name = zcache_writtenback_pages seperately, however, corresponding .val =
> &zcache_zcache_outstanding_writeback_pages and .val = &zcache_zcache_writtenback_pages,
> which are not correct.
>

Weird. I recall spotting that when I did the patches, but I wonder how
I missed this.
Ah, now I remember - I  did a silly patch by adding in #define
CONFIG_ZCACHE_WRITEBACK
in the zcache-main.c code, but forgot to try it out here.

<sigh>

Thank you for spotting and fixing it.

Reviewed-by: Konrad Rzeszutek Wilk <konrad@kernel.org>

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/debug.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
> index 254dada..d2d1fdf 100644
> --- a/drivers/staging/zcache/debug.c
> +++ b/drivers/staging/zcache/debug.c
> @@ -31,8 +31,8 @@ static struct debug_entry {
>         ATTR(eph_nonactive_puts_ignored),
>         ATTR(pers_nonactive_puts_ignored),
>  #ifdef CONFIG_ZCACHE_WRITEBACK
> -       ATTR(zcache_outstanding_writeback_pages),
> -       ATTR(zcache_writtenback_pages),
> +       ATTR(outstanding_writeback_pages),
> +       ATTR(writtenback_pages),
>  #endif
>  };
>  #undef ATTR
> --
> 1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
