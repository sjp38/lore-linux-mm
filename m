Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 61A006B01EF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:52:46 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 5/6] PM/Hibernate: Do not release preallocated memory unnecessarily (rev. 2)
Date: Thu, 14 May 2009 19:52:20 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905131040.37831.rjw@sisk.pl> <20090514110958.GA8871@elf.ucw.cz>
In-Reply-To: <20090514110958.GA8871@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905141952.21267.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 14 May 2009, Pavel Machek wrote:
> Hi!
> 
> > Since the hibernation code is now going to use allocations of memory
> > to make enough room for the image, it can also use the page frames
> > allocated at this stage as image page frames.  The low-level
> > hibernation code needs to be rearranged for this purpose, but it
> > allows us to avoid freeing a great number of pages and allocating
> > these same pages once again later, so it generally is worth doing.
> > 
> > [rev. 2: Take highmem into account correctly.]
> 
> I don't get it. What is advantage of this patch? It makes the code
> more complex... Is it supposed to be faster?

Yes, in some test cases it is reported to be faster (along with [4/6],
actually).

Besides, we'd like to get rid of shrink_all_memory() eventually and it is a
step in this direction.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
