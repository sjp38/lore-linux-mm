Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 423206B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 09:01:31 -0400 (EDT)
Date: Wed, 17 Oct 2012 14:01:25 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121017130125.GH5973@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
 <20121002150104.da57fa94.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121002150104.da57fa94.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

Hi Andrew,

On Tue, Oct 02, 2012 at 11:01:04PM +0100, Andrew Morton wrote:
> On Tue,  2 Oct 2012 17:59:11 +0100
> Will Deacon <will.deacon@arm.com> wrote:
> 
> > On x86 memory accesses to pages without the ACCESSED flag set result in the
> > ACCESSED flag being set automatically. With the ARM architecture a page access
> > fault is raised instead (and it will continue to be raised until the ACCESSED
> > flag is set for the appropriate PTE/PMD).
> > 
> > For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> > setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> > be called for a write fault.
> > 
> > This patch ensures that faults on transparent hugepages which do not result
> > in a CoW update the access flags for the faulting pmd.
> 
> Alas, the code you're altering has changed so much in linux-next that I
> am reluctant to force this fix in there myself.  Can you please
> redo/retest/resend?  You can do that on 3.7-rc1 if you like, then we
> can feed this into -rc2.

Here's the updated patch against -rc1...

Cheers,

Will

--->8
