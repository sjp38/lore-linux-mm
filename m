Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC2B6B0038
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 13:41:56 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so28847567pdj.0
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 10:41:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id gt5si84914574pbc.5.2015.01.05.10.41.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 10:41:53 -0800 (PST)
Date: Mon, 5 Jan 2015 10:41:43 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20150105184143.GA665@infradead.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org>
 <20141210141211.GD2220@wil.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141210141211.GD2220@wil.cx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:
> On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> > What is the status of this patch set?
> 
> I have no outstanding bug reports against it.  Linus told me that he
> wants to see it come through Andrew's tree.  I have an email two weeks
> ago from Andrew saying that it's on his list.  I would love to see it
> merged since it's almost a year old at this point.

And since then another month and aother merge window has passed.  Is
there any way to speed up merging big patch sets like this one?

Another one is non-blocking read one that has real life use on one
of the biggest server side webapp frameworks but doesn't seem to make
progress, which is a bit frustrating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
