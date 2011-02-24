Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D985C8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 04:49:42 -0500 (EST)
Date: Thu, 24 Feb 2011 09:49:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlbfs: correct handling of negative input to
	/proc/sys/vm/nr_hugepages
Message-ID: <20110224094912.GO15652@csn.ul.ie>
References: <1298303270-3184-1-git-send-email-pholasek@redhat.com> <20110222100235.GA15652@csn.ul.ie> <20110223161818.9876cc10.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110223161818.9876cc10.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Wed, Feb 23, 2011 at 04:18:18PM -0800, Andrew Morton wrote:
> On Tue, 22 Feb 2011 10:02:36 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Feb 21, 2011 at 04:47:49PM +0100, Petr Holasek wrote:
> > > When user insert negative value into /proc/sys/vm/nr_hugepages it will result
> > > in the setting a random number of HugePages in system (can be easily showed
> > > at /proc/meminfo output).
> > 
> > I bet you a shiny penny that the value of HugePages becomes the maximum
> > number that could be allocated by the system at the time rather than a
> > random value.
> 
> That seems to be the case from my reading.  In which case the patch
> removes probably-undocumented and possibly-useful existing behavior.
> 

It's not proof that no one does this but I'm not aware of any documentation
related to hugetlbfs that recommends writing negative values to take advantage
of this side-effect. It's more likely they simply wrote a very large number
to nr_hugepages if they wanted "as many hugepages as possible" as it makes
more intuitive sense than asking for a negative amount of pages. hugeadm at
least is not depending on this behaviour AFAIK.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
