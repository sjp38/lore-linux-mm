Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id CF60D6B0151
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 08:22:14 -0400 (EDT)
Date: Thu, 13 Sep 2012 14:22:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/3] Minor changes to common hugetlb code for ARM
Message-ID: <20120913122211.GD8055@dhcp22.suse.cz>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <20120912152759.GR21579@dhcp22.suse.cz>
 <20120912155555.GF32234@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912155555.GF32234@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Wed 12-09-12 16:55:55, Will Deacon wrote:
> On Wed, Sep 12, 2012 at 04:27:59PM +0100, Michal Hocko wrote:
> > On Tue 11-09-12 17:47:13, Will Deacon wrote:
> > > A few changes are required to common hugetlb code before the ARM support
> > > can be merged. I posted the main one previously, which has been picked up
> > > by akpm:
> > > 
> > >   http://marc.info/?l=linux-mm&m=134573987631394&w=2
> > > 
> > > The remaining three patches (included here) are all fairly minor but do
> > > affect other architectures.
> > 
> > I am quite confused. Why THP changes are required for hugetlb code for
> > ARM?
> 
> Sorry, I was being too vague. We add ARM support for THP in the same patch
> series as hugetlb, so I was loosely referring to that lot.

OK, it makes more sense now. Thanks for the clarification.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
