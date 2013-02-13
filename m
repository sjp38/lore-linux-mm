Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2FABD6B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 15:11:51 -0500 (EST)
Date: Wed, 13 Feb 2013 12:11:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-Id: <20130213121149.25a0e3bd.akpm@linux-foundation.org>
In-Reply-To: <20130213150340.GJ3460@sgi.com>
References: <20130212213534.GA5052@sgi.com>
	<20130212135726.a40ff76f.akpm@linux-foundation.org>
	<20130213150340.GJ3460@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de

On Wed, 13 Feb 2013 09:03:40 -0600
Robin Holt <holt@sgi.com> wrote:

> > But in a better world, the core kernel would support your machines
> > adequately and you wouldn't need to maintain that out-of-tree MM code. 
> > What are the prospects of this?
> 
> We can put it on our todo list.  Getting a user of this infrastructure
> will require changes by Dimitri for the GRU driver (drivers/misc/sgi-gru).
> He is currently focused on getting the design of some upcoming hardware
> finalized and design changes tested in our simulation environment so he
> will be consumed for the next several months.
> 
> If you would like, I can clean up the driver in my spare time and submit
> it for review.  Would you consider allowing its inclusion without the
> GRU driver as a user?

>From Cliff's description it sounded like that driver is
duplicating/augmenting core MM functions.  I was more wondering
whether core MM could be enhanced so that driver becomes obsolete?

> In the transition period, could we allow this change in and then remove
> the exports as part of that driver being accepted?  That would help us
> with an upcoming distro release.

I'm OK with this patch for 3.9-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
