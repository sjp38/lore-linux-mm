Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D29576B0027
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 11:10:55 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id z12so558920wgg.23
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 08:10:54 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1364870780-16296-5-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com> <1364870780-16296-5-git-send-email-liwanp@linux.vnet.ibm.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Tue, 2 Apr 2013 11:10:31 -0400
Message-ID: <CAPbh3rv08RV4Nc+tznmfb5fE-EpUaMb8Rrrrg_8pg_GiUyZPgA@mail.gmail.com>
Subject: Re: [PATCH v5 4/8] staging: zcache: fix pers_pageframes|_max aren't
 exported in debugfs
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Apr 1, 2013 at 10:46 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Before commit 9c0ad59ef ("zcache/debug: Use an array to initialize/use debugfs attributes"),
> pers_pageframes|_max are exported in debugfs, but this commit forgot use array export
> pers_pageframes|_max. This patch add pers_pageframes|_max back.

Duh! Thanks for spotting.

Reviewed-by: Konrad Rzeszutek Wilk <konrad@kernel.org>
>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/debug.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
> index e951c64..254dada 100644
> --- a/drivers/staging/zcache/debug.c
> +++ b/drivers/staging/zcache/debug.c
> @@ -21,6 +21,7 @@ static struct debug_entry {
>         ATTR(pers_ate_eph), ATTR(pers_ate_eph_failed),
>         ATTR(evicted_eph_zpages), ATTR(evicted_eph_pageframes),
>         ATTR(eph_pageframes), ATTR(eph_pageframes_max),
> +       ATTR(pers_pageframes), ATTR(pers_pageframes_max),
>         ATTR(eph_zpages), ATTR(eph_zpages_max),
>         ATTR(pers_zpages), ATTR(pers_zpages_max),
>         ATTR(last_active_file_pageframes),
> --
> 1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
