Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6376B0260
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 17:12:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id a3so17092226itg.7
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 14:12:34 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0091.hostedemail.com. [216.40.44.91])
        by mx.google.com with ESMTPS id i1si7243418itf.165.2017.12.11.14.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 14:12:33 -0800 (PST)
Message-ID: <1513030348.3036.5.camel@perches.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
From: Joe Perches <joe@perches.com>
Date: Mon, 11 Dec 2017 14:12:28 -0800
In-Reply-To: <20171211214300.GT5858@dastard>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
	 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
	 <20171208223654.GP5858@dastard> <1512838818.26342.7.camel@perches.com>
	 <20171211214300.GT5858@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue, 2017-12-12 at 08:43 +1100, Dave Chinner wrote:
> On Sat, Dec 09, 2017 at 09:00:18AM -0800, Joe Perches wrote:
> > On Sat, 2017-12-09 at 09:36 +1100, Dave Chinner wrote:
> > > 	1. Using lockdep_set_novalidate_class() for anything other
> > > 	than device->mutex will throw checkpatch warnings. Nice. (*)
> > []
> > > (*) checkpatch.pl is considered mostly harmful round here, too,
> > > but that's another rant....
> > 
> > How so?
> 
> Short story is that it barfs all over the slightly non-standard
> coding style used in XFS.
[]
> This sort of stuff is just lowest-common-denominator noise - great
> for new code and/or inexperienced developers, but not for working
> with large bodies of existing code with slightly non-standard
> conventions.

Completely reasonable.  Thanks.

Do you get many checkpatch submitters for fs/xfs?

If so, could probably do something about adding
a checkpatch file flag to the directory or equivalent.

Maybe add something like:

fs/xfs/.checkpatch

where the contents turn off most everything

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
