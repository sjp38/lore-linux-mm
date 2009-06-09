Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA2686B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 10:49:26 -0400 (EDT)
Date: Tue, 9 Jun 2009 17:31:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/16] HWPOISON: check and isolate corrupted free pages v2
Message-ID: <20090609153119.GA9211@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090603184645.68FA21D0286@basil.firstfloor.org> <20090609100229.GE14820@wotan.suse.de> <20090609130304.GF5589@localhost> <20090609132847.GC15219@wotan.suse.de> <20090609134903.GC6583@localhost> <20090609135514.GD15219@wotan.suse.de> <20090609145614.GA5590@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609145614.GA5590@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 10:56:14PM +0800, Wu Fengguang wrote:
> > Moving hot and cold functions together could become an issue
> > indeed. Mostly it probably matters a little less than code
> > within a single function due to their size. But I think gcc
> > already has options to annotate this kind of thing which we
> > could be using.
> 
> Can we tell gcc "I bet this _function_ is rarely used"?

Yes you can annotate a function as hot or cold.

 
> > So it's not such a good argument against moving things out of
> > hotpaths, or guiding in which files to place functions.
> 
> Yes.
> 
> > Anyway, in this case it is not a "nack" from me. Just that I
> > would like to see the non-fastpath code too or at least if
> > it can be thought about.
> 
> I think Andi would be pleased to present you with his buddy page
> isolation code :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
