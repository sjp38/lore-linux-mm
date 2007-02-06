Subject: Re: [RFC/PATCH] prepare_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070206095509.GA8714@infradead.org>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
	 <1170738296.2620.220.camel@localhost.localdomain>
	 <20070206095509.GA8714@infradead.org>
Content-Type: text/plain
Date: Tue, 06 Feb 2007 21:07:22 +1100
Message-Id: <1170756442.2620.234.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Eeek, this is more than fugly.  Dave Hansen suggested to move these
> checks into a file operation in response to Adam Litke's hugetlb cleanups,
> and this patch shows he was right :)

No, you don't understand... There is a fops for get_unmapped_area for
the "special" file. It's currently not called for MAP_FIXED but that can
be fixed easily enough (in fact, I have a few ideas to clean up some of
that code, it's already horrible today).

The problem is to prevent something -else- from being mapped into one of
those 256MB area once it's been switched to a different page size.

Right now, this is done via this hugetlbfs specific hack. I want to
have instead some way to have the arch "validate" the address after
get_unmapped_area(), in addition, hugetlbfs wants to "prepare" but that
could indeed be done in hugetlbfs provided fops->get_unmapped_area() if
we call it for MAP_FIXED as well.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
