Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 636B8900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 09:48:22 -0400 (EDT)
Date: Tue, 30 Aug 2011 08:48:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2]slub: explicitly document position of inserting slab
 to partial list
In-Reply-To: <1314669252.29510.49.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1108300848040.19226@router.home>
References: <1314669252.29510.49.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, linux-mm <linux-mm@kvack.org>

On Tue, 30 Aug 2011, Shaohua Li wrote:

> Adding slab to partial list head/tail is sensitive to performance. Using 0/1
> can easily cause typo. So explicitly uses DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD
> to document it to avoid we get it wrong.

I dont think we want this patch anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
