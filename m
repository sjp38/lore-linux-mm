Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 89F696B0075
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:00:50 -0400 (EDT)
Date: Thu, 28 Jun 2012 17:00:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/40] autonuma: define _PAGE_NUMA_PTE and _PAGE_NUMA_PMD
Message-ID: <20120628150046.GA6676@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-6-git-send-email-aarcange@redhat.com>
 <4FEC7487.9020909@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEC7487.9020909@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Don,

On Thu, Jun 28, 2012 at 08:13:11AM -0700, Don Morris wrote:
> On 06/28/2012 05:55 AM, Andrea Arcangeli wrote:
> > We will set these bitflags only when the pmd and pte is non present.
> > 
> 
> Just a couple grammar nitpicks.
> 
> > They work like PROT_NONE but they identify a request for the numa
> > hinting page fault to trigger.
> > 
> > Because we want to be able to set these bitflag in any established pte
> 
> these bitflags
> 
> > or pmd (while clearing the present bit at the same time) without
> > losing information, these bitflags must never be set when the pte and
> > pmd are present.
> > 
> > For _PAGE_NUMA_PTE the pte bitflag used is _PAGE_PSE, which cannot be
> > set on ptes and it also fits in between _PAGE_FILE and _PAGE_PROTNONE
> > which avoids having to alter the swp entries format.
> > 
> > For _PAGE_NUMA_PMD, we use a reserved bitflag. pmds never contain
> > swap_entries but if in the future we'll swap transparent hugepages, we
> > must keep in mind not to use the _PAGE_UNUSED2 bitflag in the swap
> > entry format and to start the swap entry offset above it.
> > 
> > PAGE_UNUSED2 is used by Xen but only on ptes established by ioremap,
> > but it's never used on pmds so there's no risk of collision with Xen.
> 
> Maybe "but only on ptes established by ioremap, never on pmds so
> there's no risk of collision with Xen." ? The extra "but" just
> doesn't flow in the original.

Agreed and applied, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
