Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 94BF88D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 10:35:36 -0400 (EDT)
Date: Wed, 3 Nov 2010 09:35:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/3] Linux/Guest unmapped page cache control
In-Reply-To: <20101028224008.32626.69769.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011030932260.10599@router.home>
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain> <20101028224008.32626.69769.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010, Balbir Singh wrote:

> A lot of the code is borrowed from zone_reclaim_mode logic for
> __zone_reclaim(). One might argue that the with ballooning and
> KSM this feature is not very useful, but even with ballooning,

Interesting use of zone reclaim. I am having a difficult time reviewing
the patch since you move and modify functions at the same time. Could you
separate that out a bit?

> +#define UNMAPPED_PAGE_RATIO 16

Maybe come up with a scheme that allows better configuration of the
mininum? I think in some setting we may want an absolute limit and in
other a fraction of something (total zone size or working set?)


> +bool should_balance_unmapped_pages(struct zone *zone)
> +{
> +	if (unmapped_page_control &&
> +		(zone_unmapped_file_pages(zone) >
> +			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))
> +		return true;
> +	return false;
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
