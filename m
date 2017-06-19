Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4516B0397
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:35:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p14so109871448pgc.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 02:35:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w64si7834259pgd.208.2017.06.19.02.35.08
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 02:35:08 -0700 (PDT)
Date: Mon, 19 Jun 2017 10:35:18 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 0/3] mm: huge pages: Misc fixes for issues found
 during fuzzing
Message-ID: <20170619093518.GB2702@arm.com>
References: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
 <20170615133252.3191c75d7b33a8bb7cad2004@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615133252.3191c75d7b33a8bb7cad2004@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz

On Thu, Jun 15, 2017 at 01:32:52PM -0700, Andrew Morton wrote:
> On Tue, 13 Jun 2017 11:28:39 +0100 Will Deacon <will.deacon@arm.com> wrote:
> 
> > This is v2 of the patches previously posted here:
> > 
> >    http://www.spinics.net/lists/linux-mm/msg128577.html
> > 
> > Changes since v1 include:
> > 
> >   * Use smp_mb() instead of smp_mb__before_atomic() before atomic_set()
> >   * Added acks and fixes tag
> > 
> > Feedback welcome,
> > 
> > Will
> > 
> > --->8
> > 
> > Mark Rutland (1):
> >   mm: numa: avoid waiting on freed migrated pages
> > 
> > Will Deacon (2):
> >   mm/page_ref: Ensure page_ref_unfreeze is ordered against prior
> >     accesses
> >   mm: migrate: Stabilise page count when migrating transparent hugepages
> 
> I marked [1/3] for -stable backporting and held the other two for
> 4.13-rc1.  Maybe that wasn't appropriate...

I think that's about right. Patches 2 and 3 fix issues found by inspection,
rather than something we've knowingly run into.

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
