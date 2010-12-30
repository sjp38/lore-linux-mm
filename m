Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CA2E16B00AE
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 11:27:10 -0500 (EST)
Date: Thu, 30 Dec 2010 11:26:11 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH R2 5/7] xen/balloon: Protect before CPU exhaust by
 event/x process
Message-ID: <20101230162611.GA24313@dumpdata.com>
References: <20101229170541.GJ2743@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101229170541.GJ2743@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -static int increase_reservation(unsigned long nr_pages)
> +static enum bp_state increase_reservation(unsigned long nr_pages)
>  {
> +	enum bp_state state = BP_DONE;
> +	int rc;
>  	unsigned long  pfn, i, flags;
>  	struct page   *page;
> -	long           rc;

How come? Is it just a cleanup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
