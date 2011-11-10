Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 458006B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:45:03 -0500 (EST)
Date: Thu, 10 Nov 2011 08:44:59 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] slub: fix a code merge error
In-Reply-To: <1320912260.22361.247.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1111100844410.19196@router.home>
References: <1320912260.22361.247.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, penberg@kernel.org

On Thu, 10 Nov 2011, Shaohua Li wrote:

> Looks there is a merge error in the slub tree. DEACTIVATE_TO_TAIL != 1.
> And this will cause performance regression.

Thanks.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
