Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0A7846B00E7
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 11:55:57 -0400 (EDT)
Date: Wed, 12 Sep 2012 16:55:55 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/3] Minor changes to common hugetlb code for ARM
Message-ID: <20120912155555.GF32234@mudshark.cambridge.arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <20120912152759.GR21579@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912152759.GR21579@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Sep 12, 2012 at 04:27:59PM +0100, Michal Hocko wrote:
> On Tue 11-09-12 17:47:13, Will Deacon wrote:
> > A few changes are required to common hugetlb code before the ARM support
> > can be merged. I posted the main one previously, which has been picked up
> > by akpm:
> > 
> >   http://marc.info/?l=linux-mm&m=134573987631394&w=2
> > 
> > The remaining three patches (included here) are all fairly minor but do
> > affect other architectures.
> 
> I am quite confused. Why THP changes are required for hugetlb code for
> ARM?

Sorry, I was being too vague. We add ARM support for THP in the same patch
series as hugetlb, so I was loosely referring to that lot.

> Besides that I would suggest adding Andrea to the CC (added now the
> whole series can be found here http://lkml.org/lkml/2012/9/11/322) list
> for all THP changes.

Thanks for that, I'll add Andrew to future submissions.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
