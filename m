Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 173A56B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 20:29:47 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1252911eek.40
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 17:29:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si4853115eer.237.2014.04.08.17.29.44
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 17:29:45 -0700 (PDT)
Date: Tue, 8 Apr 2014 20:29:15 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add support for gigantic page allocation
 at runtime
Message-ID: <20140408202915.7ad557c7@redhat.com>
In-Reply-To: <20140408155102.d55e3b798681e316d957f383@linux-foundation.org>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
	<1396462128-32626-5-git-send-email-lcapitulino@redhat.com>
	<1396893509-x52fgnka@n-horiguchi@ah.jp.nec.com>
	<20140407144935.259d4301@redhat.com>
	<20140408155102.d55e3b798681e316d957f383@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Tue, 8 Apr 2014 15:51:02 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 7 Apr 2014 14:49:35 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > > > ---
> > > >  arch/x86/include/asm/hugetlb.h |  10 +++
> > > >  mm/hugetlb.c                   | 177 ++++++++++++++++++++++++++++++++++++++---
> > > >  2 files changed, 176 insertions(+), 11 deletions(-)
> > > > 
> > > > diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> > > > index a809121..2b262f7 100644
> > > > --- a/arch/x86/include/asm/hugetlb.h
> > > > +++ b/arch/x86/include/asm/hugetlb.h
> > > > @@ -91,6 +91,16 @@ static inline void arch_release_hugepage(struct page *page)
> > > >  {
> > > >  }
> > > >  
> > > > +static inline int arch_prepare_gigantic_page(struct page *page)
> > > > +{
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +static inline void arch_release_gigantic_page(struct page *page)
> > > > +{
> > > > +}
> > > > +
> > > > +
> > > >  static inline void arch_clear_hugepage_flags(struct page *page)
> > > >  {
> > > >  }
> > > 
> > > These are defined only on arch/x86, but called in generic code.
> > > Does it cause build failure on other archs?
> > 
> > Hmm, probably. The problem here is that I'm unable to test this
> > code in other archs. So I think the best solution for the first
> > merge is to make the build of this feature conditional to x86_64?
> > Then the first person interested in making this work in other
> > archs add the generic code. Sounds reasonable?
> 
> These functions don't actually do anything so if and when other
> architectures come along to implement this feature, their developers
> won't know what you were thinking when you added them.  So how about
> some code comments to explain their roles and responsibilities?
> 
> Or just delete them altogether and let people add them (or something
> similar) if and when the need arises.  It's hard to tell when one lacks
> telepathic powers, sigh.

That's exactly what I did for v2 (already posted).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
