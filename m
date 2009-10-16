Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A7CD6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 12:56:54 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7A4C982C2BE
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:01:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ta8k8PfxrI9V for <linux-mm@kvack.org>;
	Fri, 16 Oct 2009 13:01:29 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B2FFA82C6D5
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 13:01:25 -0400 (EDT)
Date: Fri, 16 Oct 2009 12:48:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/2][v2] powerpc: Make the CMM memory hotplug aware
In-Reply-To: <4AD7681C.7060800@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.1.10.0910161246010.6120@gentwo.org>
References: <20091002184458.GC4908@austin.ibm.com> <20091002185248.GD4908@austin.ibm.com> <4ACDD71D.30809@linux.vnet.ibm.com> <20091008131355.GA22118@austin.ibm.com> <4AD7681C.7060800@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: gerald.schaefer@de.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, Gerald Schaefer wrote:

> > The pages allocated as __GFP_MOVABLE are used to store the list of pages
> > allocated by the balloon.  They reference virtual addresses and it would
> > be fine for the kernel to migrate the physical pages for those, the
> > balloon would not notice this.
>
> Does page migration really work for kernel pages that were allocated
> with __get_free_page()? I was wondering if we can do this on s390, where
> we have a 1:1 mapping of kernel virtual to physical addresses, but
> looking at migrate_pages() and friends, it seems that kernel pages
> w/o mapping and rmap should not be migrateable at all. Any thoughts from
> the memory migration experts?

page migration only works for pages where we have some way of accounting
for all the references to a page. This usually mean using reverse mappings
(anon list, radix trees and page tables).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
