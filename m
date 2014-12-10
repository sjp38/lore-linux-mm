Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 62AC86B0074
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:17:09 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so2848712pac.8
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:17:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id t3si5220652pdc.177.2014.12.10.06.17.07
        for <linux-mm@kvack.org>;
        Wed, 10 Dec 2014 06:17:08 -0800 (PST)
Date: Wed, 10 Dec 2014 09:12:11 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20141210141211.GD2220@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141210140347.GA23252@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> What is the status of this patch set?

I have no outstanding bug reports against it.  Linus told me that he
wants to see it come through Andrew's tree.  I have an email two weeks
ago from Andrew saying that it's on his list.  I would love to see it
merged since it's almost a year old at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
