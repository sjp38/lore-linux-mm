Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7C8F6B00BB
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:12:24 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0018C82C4AA
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:16:20 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id agijnSCSR-gK for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 15:16:19 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B80D82C4AC
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:16:19 -0500 (EST)
Date: Tue, 17 Feb 2009 15:04:51 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <84144f020902171143i5844ef83h20cb4bee4f65c904@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0902171504090.24395@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de>  <200902041748.41801.nickpiggin@yahoo.com.au>  <20090204152709.GA4799@csn.ul.ie>  <200902051459.30064.nickpiggin@yahoo.com.au>  <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
 <alpine.DEB.1.10.0902171120040.27813@qirst.com>  <1234890096.11511.6.camel@penberg-laptop>  <alpine.DEB.1.10.0902171204070.15929@qirst.com>  <20090217181157.GA2158@cmpxchg.org> <84144f020902171143i5844ef83h20cb4bee4f65c904@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Feb 2009, Pekka Enberg wrote:

> >> +#define SLUB_MAX_SIZE (2 * PAGE_SIZE)
>
> On Tue, Feb 17, 2009 at 8:11 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > This relies on PAGE_SIZE being 4k.  If you want 8k, why don't you say
> > so?  Pekka did this explicitely.
>
> That could be a problem, sure. Especially for architecture that have 64 K pages.

You could likely put a complicated formula in there instead. But 2 *
PAGE_SIZE is simple and will work on all platforms regardless of pagesize.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
