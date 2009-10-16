Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 240576B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 23:26:30 -0400 (EDT)
Date: Thu, 15 Oct 2009 20:26:26 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
In-Reply-To: <20091016120242.AF31.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910152018090.12287@kernalhack.brc.ubc.ca>
References: <20091016111041.6ffc59c9.minchan.kim@barrios-desktop> <20091016022011.GA22706@localhost> <20091016120242.AF31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 16 Oct 2009, KOSAKI Motohiro wrote:

> > I would prefer to just remove it - to make the code simple :)
> 
> +1 me.
> 
> Thank you, Vincent. Your effort was pretty clear and good.
> but your mesurement data didn't persuade us.

That is all right :). While it takes time, but I enjoy it.

Thank you all for the reviewing. 

Andrew: Would you please drop the mm-vsmcan-check-shrink_active_list-sc-isolate_pages-return-value.patch 
patch from mmotm? Thank you for your time.

Thanks,

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
