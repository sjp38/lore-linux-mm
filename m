Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 119A96B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 15:53:24 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so3509172pdj.14
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:53:23 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id nt8si8243862pdb.253.2014.12.10.12.53.21
        for <linux-mm@kvack.org>;
        Wed, 10 Dec 2014 12:53:23 -0800 (PST)
Date: Thu, 11 Dec 2014 07:53:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20141210205318.GD24183@dastard>
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
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:
> On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> > What is the status of this patch set?
> 
> I have no outstanding bug reports against it.  Linus told me that he
> wants to see it come through Andrew's tree.  I have an email two weeks
> ago from Andrew saying that it's on his list.  I would love to see it
> merged since it's almost a year old at this point.

Yup, and I've been sitting on the XFS patches to enable DAX for
quite a few months. I'm waiting for it to hit the upstream trees so
I can push it...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
