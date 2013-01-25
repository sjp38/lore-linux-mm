Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 480AC6B0009
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 20:33:03 -0500 (EST)
Received: by mail-vb0-f45.google.com with SMTP id p1so5853781vbi.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 17:33:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Fri, 25 Jan 2013 10:33:02 +0900
Message-ID: <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth, frontswap guys

On Tue, Jan 8, 2013 at 5:24 AM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> zs_create_pool() currently takes a gfp flags argument
> that is used when growing the memory pool.  However
> it is not used in allocating the metadata for the pool
> itself.  That is currently hardcoded to GFP_KERNEL.
>
> zswap calls zs_create_pool() at swapon time which is done
> in atomic context, resulting in a "might sleep" warning.

I didn't review this all series, really sorry but totday I saw Nitin
added Acked-by so I'm afraid Greg might get it under my radar. I'm not
strong against but I would like know why we should call frontswap_init
under swap_lock? Is there special reason?

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
