Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 94BCC6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 09:28:57 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id 5so1832743pdd.31
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 06:28:56 -0700 (PDT)
Date: Sat, 13 Apr 2013 06:28:54 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH PART2 v4 6/6] staging: ramster: add how-to for ramster
Message-ID: <20130413132854.GA28650@kroah.com>
References: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365858092-21920-7-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365858092-21920-7-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Sat, Apr 13, 2013 at 09:01:32PM +0800, Wanpeng Li wrote:
> Add how-to for ramster.
> 
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Singed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/ramster/HOWTO.txt |  257 ++++++++++++++++++++++++++++++
>  1 file changed, 257 insertions(+)
>  create mode 100644 drivers/staging/zcache/ramster/HOWTO.txt
> 
> diff --git a/drivers/staging/zcache/ramster/HOWTO.txt b/drivers/staging/zcache/ramster/HOWTO.txt
> new file mode 100644
> index 0000000..a4ee979
> --- /dev/null
> +++ b/drivers/staging/zcache/ramster/HOWTO.txt
> @@ -0,0 +1,257 @@
> +Version: 130309
> + Dan Magenheimer <dan.magenheimer@oracle.com>

If Dan wrote this, why are you listing yourself as the author of this
patch?

> +CHANGELOG:
> +v5-120214->120817: updated for merge into new zcache codebase
> +v4-120126->v5-120214: updated for V5
> +111227->v4-120126: added info on selfshrinking and rebooting
> +111227->v4-120126: added more info for tracking RAMster stats
> +111227->v4-120126: CONFIG_PREEMPT_NONE no longer necessary
> +111227->v4-120126: cleancache now works completely so no need to disable it

That is not needed in an in-kernel file, please remove it.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
