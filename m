Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 166666B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 23:31:27 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id lx4so940619iec.20
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 20:31:26 -0700 (PDT)
Received: from qmta06.westchester.pa.mail.comcast.net (qmta06.westchester.pa.mail.comcast.net. [2001:558:fe14:43:76:96:62:56])
        by mx.google.com with ESMTP id nz2si3532658icc.76.2014.09.16.20.31.26
        for <linux-mm@kvack.org>;
        Tue, 16 Sep 2014 20:31:26 -0700 (PDT)
Date: Tue, 16 Sep 2014 22:31:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Best way to pin a page in ext4?
In-Reply-To: <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
Message-ID: <alpine.DEB.2.11.1409162230160.12769@gentwo.org>
References: <20140915185102.0944158037A@closure.thunk.org> <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca> <20140916180759.GI6205@thunk.org> <alpine.LSU.2.11.1409161555120.5144@eggly.anvils>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Tue, 16 Sep 2014, Hugh Dickins wrote:

> On the page migration issue: it's not quite as straightforward as
> Christoph suggests.  He and I agree completely that mlocked pages
> should be migratable, but some real-time-minded people disagree:
> so normal compaction is still forbidden to migrate mlocked pages in
> the vanilla kernel (though we in Google patch that prohibition out).
> So pinning by refcount is no worse for compaction than mlocking,
> in the vanilla kernel.

Note though that compaction is not the only mechanism that uses page
migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
