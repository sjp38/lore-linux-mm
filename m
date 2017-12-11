Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63C026B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:43:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t9so13915295pgu.1
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:43:05 -0800 (PST)
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id bf5si10693280plb.578.2017.12.11.13.43.02
        for <linux-mm@kvack.org>;
        Mon, 11 Dec 2017 13:43:03 -0800 (PST)
Date: Tue, 12 Dec 2017 08:43:00 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171211214300.GT5858@dastard>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
 <20171208223654.GP5858@dastard>
 <1512838818.26342.7.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512838818.26342.7.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Sat, Dec 09, 2017 at 09:00:18AM -0800, Joe Perches wrote:
> On Sat, 2017-12-09 at 09:36 +1100, Dave Chinner wrote:
> > 	1. Using lockdep_set_novalidate_class() for anything other
> > 	than device->mutex will throw checkpatch warnings. Nice. (*)
> []
> > (*) checkpatch.pl is considered mostly harmful round here, too,
> > but that's another rant....
> 
> How so?

Short story is that it barfs all over the slightly non-standard
coding style used in XFS.  It generates enough noise on incidental
things we aren't important that it complicates simple things. e.g. I
just moved a block of defines from one header to another, and
checkpatch throws about 10 warnings on that because of whitespace.
I'm just moving code - I don't want to change it and it doesn't need
to be modified because it is neat and easy to read and is obviously
correct. A bunch of prototypes I added another parameter to gets
warnings because it uses "unsigned" for an existing parameter that
I'm not changing. And so on.

This sort of stuff is just lowest-common-denominator noise - great
for new code and/or inexperienced developers, but not for working
with large bodies of existing code with slightly non-standard
conventions. Churning *lots* of code we otherwise wouldn't touch
just to shut up checkpatch warnings takes time, risks regressions
and makes it harder to trace the history of the code when we are
trying to track down bugs.

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
