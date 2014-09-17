Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6A06B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:57:23 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2259943pab.1
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 06:57:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tz2si35053070pab.110.2014.09.17.06.57.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 06:57:22 -0700 (PDT)
Date: Wed, 17 Sep 2014 15:57:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Best way to pin a page in ext4?
Message-ID: <20140917135719.GK2840@worktop.localdomain>
References: <20140915185102.0944158037A@closure.thunk.org>
 <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca>
 <20140916180759.GI6205@thunk.org>
 <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
 <alpine.DEB.2.11.1409162230160.12769@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1409162230160.12769@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Tue, Sep 16, 2014 at 10:31:24PM -0500, Christoph Lameter wrote:
> On Tue, 16 Sep 2014, Hugh Dickins wrote:
> 
> > On the page migration issue: it's not quite as straightforward as
> > Christoph suggests.  He and I agree completely that mlocked pages
> > should be migratable, but some real-time-minded people disagree:
> > so normal compaction is still forbidden to migrate mlocked pages in
> > the vanilla kernel (though we in Google patch that prohibition out).
> > So pinning by refcount is no worse for compaction than mlocking,
> > in the vanilla kernel.
> 
> Note though that compaction is not the only mechanism that uses page
> migration.

Agreed, and not all migration paths check for mlocked iirc. ISTR it is
very much possible for mlocked pages to get migrated in mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
