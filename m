Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1E1D36B00B7
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 14:04:14 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 02B843056BC
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 14:09:36 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EjqRU8pwccIz for <linux-mm@kvack.org>;
	Tue,  3 Mar 2009 14:09:35 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 581113056BE
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 14:09:25 -0500 (EST)
Date: Tue, 3 Mar 2009 13:53:47 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
In-Reply-To: <20090303135254.GE10577@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903031350020.18013@qirst.com>
References: <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org> <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com>
 <20090226171549.GH32756@csn.ul.ie> <alpine.DEB.1.10.0902261226370.26440@qirst.com> <20090227113333.GA21296@wotan.suse.de> <alpine.DEB.1.10.0902271039440.31801@qirst.com> <20090303135254.GE10577@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 2009, Mel Gorman wrote:

> > And only if the page allocator gets fast enough to be usable for
> > allocs instead of quicklists.
> It appears the x86 doesn't even use the quicklists. I know patches for
> i386 support used to exist, what happened with them?

The x86 patches were not applied because of an issue with early NUMA
freeing. The problem has been fixed but the x86 patches were left
unmerged. There was also an issue with the quicklists growing too large.

> That aside, I think we could win slightly by just knowing when a page is
> zeroed and being freed back to the allocator such as when the quicklists
> are being drained. I wrote a patch along those lines but it started
> getting really messy on x86 so I'm postponing it for the moment.

quicklist tied into the tlb freeing logic. The tlb freeing logic could
itself keep a list of zeroed pages which may be cleaner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
