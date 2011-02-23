Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 595858D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 09:45:36 -0500 (EST)
Date: Wed, 23 Feb 2011 15:45:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110223144509.GG31195@random.random>
References: <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <20110214022524.GA18198@sli10-conroe.sh.intel.com>
 <20110222142559.GD15652@csn.ul.ie>
 <1298438954.19589.7.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298438954.19589.7.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, "Shi, Alex" <alex.shi@intel.com>

On Wed, Feb 23, 2011 at 01:29:14PM +0800, Shaohua Li wrote:
> Fixing it will let more people enable THP by default. but anyway we will
> disable it now if the issue can't be fixed.

Did you try what happens with transparent_hugepage=madvise? If that
doesn't fix it, it's min_free_kbytes issue.

Also if you're using an heavily threaded application, decreasing the
stack size with pthread_attr_setstack to something like 16k will fix
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
