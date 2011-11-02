Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 96C906B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 05:46:13 -0400 (EDT)
Date: Wed, 2 Nov 2011 04:46:02 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH 0/3] Add support for non-CPU TLBs in MMU-Notifiers
Message-ID: <20111102094601.GN28536@sgi.com>
References: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joerg.roedel@amd.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, joro@8bytes.org

On Fri, Oct 21, 2011 at 02:21:45PM +0200, Joerg Roedel wrote:
> Hi,
> 
> this is my first attempt to add support for non-CPU TLBs to the
> MMU-Notifier framework. This will be used by the AMD IOMMU driver for
> the next generation of hardware. The next version of the AMD IOMMU can
> walk page-tables in AMD64 long-mode format (with setting
> accessed/dirty-bits atomically) and save the translations in its own
> TLB. Page faulting for IO devices is supported too. This will be used to
> let hardware devices share page-tables with CPU processes and access
> their memory directly. Please look at
> 
> 	http://support.amd.com/us/Processor_TechDocs/48882.pdf

...

Did this patch set get any review or traction?  Perhaps you should have
included the linux-mm@kvack.org mailing list.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
