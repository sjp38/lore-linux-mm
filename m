Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id EC8646B0075
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:29:05 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id hq11so1430466vcb.31
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:29:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id xq8si2104463vdc.76.2014.12.10.06.29.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:29:04 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on memory storage
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<20141210140347.GA23252@infradead.org> <20141210141211.GD2220@wil.cx>
Date: Wed, 10 Dec 2014 09:28:33 -0500
In-Reply-To: <20141210141211.GD2220@wil.cx> (Matthew Wilcox's message of "Wed,
	10 Dec 2014 09:12:11 -0500")
Message-ID: <x49388ntw8e.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Matthew Wilcox <willy@linux.intel.com> writes:

> On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
>> What is the status of this patch set?
>
> I have no outstanding bug reports against it.  Linus told me that he
> wants to see it come through Andrew's tree.  I have an email two weeks
> ago from Andrew saying that it's on his list.  I would love to see it
> merged since it's almost a year old at this point.

I'd also like to see this go in soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
