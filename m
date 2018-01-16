Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC4328024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:23:42 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id q3so11374838ybm.11
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 15:23:42 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id e4si274230ybn.454.2018.01.16.15.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 15:23:41 -0800 (PST)
Date: Tue, 16 Jan 2018 18:23:35 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
Message-ID: <20180116232335.GM8249@thunk.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116145240.GD30073@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org

On Tue, Jan 16, 2018 at 06:52:40AM -0800, Matthew Wilcox wrote:
> 
> I see the improvements that Facebook have been making to the nbd driver,
> and I think that's a wonderful thing.  Maybe the outcome of this topic
> is simply: "Shut up, Matthew, this is good enough".
> 
> It's clear that there's an appetite for userspace block devices; not for
> swap devices or the root device, but for accessing data that's stored
> in that silo over there, and I really don't want to bring that entire
> mess of CORBA / Go / Rust / whatever into the kernel to get to it,
> but it would be really handy to present it as a block device.

... and using iSCSI was too painful and heavyweight.

Google has an iblock device implementation, so you can use that as
confirmation that there certainly has been a desire for such a thing.
In fact, we're happily using it in production even as we speak.

We have been (tentatively) planning on presenting it at OSS North
America later in the year, since the Vault conference is no longer
with us, but we could probably put together a quick presentation for
LSF/MM if there is interest.

There were plans to do something using page cache tricks (what we were
calling the "zero copy" option), but we decided to start with
something simpler, more reliable, so long as it was less overhead and
pain than iSCSI (which was simply an over-engineered solution for our
use case), it was all upside.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
