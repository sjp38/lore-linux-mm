Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDDD6B025F
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 04:39:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a192so2467206pge.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 01:39:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si4460616pgt.437.2017.10.05.01.39.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 01:39:35 -0700 (PDT)
Date: Thu, 5 Oct 2017 10:39:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: readahead: Increase maximum readahead window
Message-ID: <20171005083933.GB28132@quack2.suse.cz>
References: <20171004091205.468-1-jack@suse.cz>
 <20171004174151.GA6497@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004174151.GA6497@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed 04-10-17 10:41:51, Darrick J. Wong wrote:
> On Wed, Oct 04, 2017 at 11:12:05AM +0200, Jan Kara wrote:
> > Increase default maximum allowed readahead window from 128 KB to 512 KB.
> > This improves performance for some workloads (see below for details) where
> > ability to scale readahead window to larger sizes allows for better total
> > throughput while chances for regression are rather low given readahead
> > window size is dynamically computed based on observation (and thus it never
> > grows large for workloads with a random read pattern).
> > 
> > Note that the same tuning can be done using udev rules or by manually setting
> > the sysctl parameter however we believe the new value is a better default most
> > users will want to use. As a data point we carry this patch in SUSE kernels
> > for over 8 years.
> > 
> > Some data from the last evaluation of this patch (on 4.4-based kernel, I can
> > rerun those tests on a newer kernel but nothing has changed in the readahead
> > area since 4.4). The patch was evaluated on two machines
> 
> This is purely speculating, but I think this is worth at least a quick
> retry on 4.14 to see what's changed in the past 10 kernel release.  For
> one thing, ext3 no longer exists, and XFS' file IO path has changed
> quite a lot since then.

ext3 in this test is actually using ext4 driver already, so that has not
changed. I agree XFS has changed quite a bit so results might differ there.
I can rerun it with current kernel to see whether XFS behavior changed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
