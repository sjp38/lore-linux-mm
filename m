Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC3646B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:43:03 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so16085916wib.4
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:43:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb12si36819459wjc.160.2015.01.12.09.43.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 09:43:02 -0800 (PST)
Date: Mon, 12 Jan 2015 18:42:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Message-ID: <20150112174258.GN4468@quack.suse.cz>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <20150108122448.GA18034@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150108122448.GA18034@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 08-01-15 04:24:48, Christoph Hellwig wrote:
> > This patchset passes xfstests and various benchmarks and stress
> > workloads, so the real question is now:
> > 
> > 	What have I missed?
> > 
> > Comments, thoughts, flames?
> 
> Why is this done in XFS and not in generic code?
  I was also thinking about this. In the end I decided not to propose this
since the new rw-lock would grow struct inode and is actually necessary
only for filesystems implementing hole punching AFAICS. And that isn't
supported by that many filesystems. So fs private implementation which
isn't that complicated looked like a reasonable solution to me...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
