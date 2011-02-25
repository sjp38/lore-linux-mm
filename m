Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 148268D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:00 -0500 (EST)
Date: Fri, 25 Feb 2011 17:30:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2] hugetlbfs: correct handling of negative input to
	/proc/sys/vm/nr_hugepages
Message-ID: <20110225173030.GC9468@csn.ul.ie>
References: <4D6419C0.8080804@redhat.com> <20110224141034.d2dfb7de.akpm@linux-foundation.org> <20110224141335.978066c5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110224141335.978066c5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Thu, Feb 24, 2011 at 02:13:35PM -0800, Andrew Morton wrote:
> On Thu, 24 Feb 2011 14:10:34 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 22 Feb 2011 21:17:04 +0100
> > Petr Holasek <pholasek@redhat.com> wrote:
> > 
> > > When user insert negative value into /proc/sys/vm/nr_hugepages it will 
> > > result
> > > in the setting a random number of HugePages in system
> > 
> > Is this true?  afacit the kernel will allocate as many pages as it can
> > and will then set /proc/sys/vm/nr_hugepages to reflect the result. 
> > That's not random.
> > 
> 
> Assuming the above to be correct, I altered the changelog thusly:
> 

AFAIK, it's correct.

> : When the user inserts a negative value into /proc/sys/vm/nr_hugepages it
> : will cause the kernel to allocate as many hugepages as possible and to
> : then update /proc/meminfo to reflect this.
> :
> : This changes the behavior so that the negative input will result in
> : nr_hugepages value being unchanged.
> 
> and given that, I don't really see why we should change the existing behaviour.
> 

The main motivation is that asking the kernel for -1 pages and getting a
sensible response just feels wrong. The second reason I'd guess is that an
administrator script that was buggy (or raced with a second) instance that
accidentally wrote a negative number to the proc interface would try allocating
all memory as huge pages instead of reducing the number of hugepages as
was probably intended. Totally hypothetical case of course, I haven't
actually heard of this happening to anyone.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
