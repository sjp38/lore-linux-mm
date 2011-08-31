Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CA2326B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 22:27:37 -0400 (EDT)
Subject: Re: [patch 2/2]slub: explicitly document position of inserting
 slab to partial list
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1108300848040.19226@router.home>
References: <1314669252.29510.49.camel@sli10-conroe>
	 <alpine.DEB.2.00.1108300848040.19226@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 31 Aug 2011 10:29:48 +0800
Message-ID: <1314757788.29510.59.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, linux-mm <linux-mm@kvack.org>

On Tue, 2011-08-30 at 21:48 +0800, Christoph Lameter wrote:
> On Tue, 30 Aug 2011, Shaohua Li wrote:
> 
> > Adding slab to partial list head/tail is sensitive to performance. Using 0/1
> > can easily cause typo. So explicitly uses DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD
> > to document it to avoid we get it wrong.
> 
> I dont think we want this patch anymore.
I do think using 0/1 isn't good. A more meaningful name is better to
avoid typo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
