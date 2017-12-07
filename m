Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30AA46B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 11:06:43 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id w141so3574271ywa.2
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 08:06:43 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m84si786371ybc.812.2017.12.07.08.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Dec 2017 08:06:42 -0800 (PST)
Date: Thu, 7 Dec 2017 11:06:34 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171207160634.il3vt5d6a4v5qesi@thunk.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206140648.GB32044@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 06, 2017 at 06:06:48AM -0800, Matthew Wilcox wrote:
> > Unfortunately for you, I don't find arguments along the lines of
> > "lockdep will save us" at all convincing.  lockdep already throws
> > too many false positives to be useful as a tool that reliably and
> > accurately points out rare, exciting, complex, intricate locking
> > problems.
> 
> But it does reliably and accurately point out "dude, you forgot to take
> the lock".  It's caught a number of real problems in my own testing that
> you never got to see.

The problem is that if it has too many false positives --- and it's
gotten *way* worse with the completion callback "feature", people will
just stop using Lockdep as being too annyoing and a waste of developer
time when trying to figure what is a legitimate locking bug versus
lockdep getting confused.

<Rant>I can't even disable the new Lockdep feature which is throwing
lots of new false positives --- it's just all or nothing.</Rant>

Dave has just said he's already stopped using Lockdep, as a result.

     	      	   			      - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
