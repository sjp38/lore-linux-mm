Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 460FC6B005C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 10:50:46 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 38C0882C735
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 10:55:42 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zei+1IpO006P for <linux-mm@kvack.org>;
	Fri, 27 Feb 2009 10:55:42 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C7A8182C73D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 10:55:39 -0500 (EST)
Date: Fri, 27 Feb 2009 10:40:17 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
In-Reply-To: <20090227113333.GA21296@wotan.suse.de>
Message-ID: <alpine.DEB.1.10.0902271039440.31801@qirst.com>
References: <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org>
 <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com> <20090226171549.GH32756@csn.ul.ie> <alpine.DEB.1.10.0902261226370.26440@qirst.com> <20090227113333.GA21296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 2009, Nick Piggin wrote:

> > I hope we can get rid of various ugly elements of the quicklists if the
> > page allocator would offer some sort of support. I would think that the
>
> Only if it provides significant advantages over existing quicklists or
> adds *no* extra overhead to the page allocator common cases. :)

And only if the page allocator gets fast enough to be usable for
allocs instead of quicklists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
