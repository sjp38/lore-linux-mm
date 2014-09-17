Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id AB8A56B0038
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:56:23 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id e4so1284715wiv.5
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 06:56:23 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gn3si6763023wib.26.2014.09.17.06.56.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 06:56:21 -0700 (PDT)
Date: Wed, 17 Sep 2014 15:56:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Best way to pin a page in ext4?
Message-ID: <20140917135614.GJ2840@worktop.localdomain>
References: <20140915185102.0944158037A@closure.thunk.org>
 <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
 <20140916180759.GI6205@thunk.org>
 <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, Christoph Lameter <cl@linux.com>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Tue, Sep 16, 2014 at 05:07:18PM -0700, Hugh Dickins wrote:
> On the page migration issue: it's not quite as straightforward as
> Christoph suggests.  He and I agree completely that mlocked pages
> should be migratable, but some real-time-minded people disagree:
> so normal compaction is still forbidden to migrate mlocked pages in
> the vanilla kernel (though we in Google patch that prohibition out).
> So pinning by refcount is no worse for compaction than mlocking,
> in the vanilla kernel.

These realtime people are fully aware of this -- they should be at
least, I've been telling them for years.

Also, they would be very happy with means to actually pin pages -- as
per the patches Christoph referred to. The advantage of also having
mpin() and co is that we can migrate the memory into non-movable blocks
before returning etc.

In any case, I think we can (and should) change the behaviour of mlock
to be migratable (possibly with an easy way to revert in -rt for
migratory purposes until we get mpin sorted).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
