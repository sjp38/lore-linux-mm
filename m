Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0HHVfkS004598
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 12:31:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0HHU61s264510
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 10:30:06 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0HHVfKJ009719
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 10:31:41 -0700
Subject: Re: [PATCH] zonelists gfp_zone() is really gfp_zonelist()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060117155010.GA16135@shadowen.org>
References: <20060117155010.GA16135@shadowen.org>
Content-Type: text/plain
Date: Tue, 17 Jan 2006 09:31:39 -0800
Message-Id: <1137519100.5526.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-17 at 15:50 +0000, Andy Whitcroft wrote:
> +/*
> + * Extract the gfp modifier space index from the flags word.  Note that
> + * this is not a zone number.
> + */
> +static inline int gfp_zonelist(gfp_t gfp)
>  {
> -       int zone = GFP_ZONEMASK & (__force int) gfp;
> -       BUG_ON(zone >= GFP_ZONETYPES);
> -       return zone;
> +       int zonelist = GFP_ZONEMASK & (__force int) gfp;
> +       BUG_ON(zonelist >= GFP_ZONETYPES);
> +       return zonelist;
>  } 

Hmm, but it's not really a zonelist, either.  It's an index into an
array of zonelists that gets you a zonelist.  How about
gfp_to_zonelist_nr()?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
