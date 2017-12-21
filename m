Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE6F16B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:06:49 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id k186so7620989ith.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 04:06:49 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p203si4848657itg.131.2017.12.21.04.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 04:06:36 -0800 (PST)
From: Knut Omang <knut.omang@oracle.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
	<Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
	<20171208223654.GP5858@dastard> <1512838818.26342.7.camel@perches.com>
	<20171211214300.GT5858@dastard> <1513030348.3036.5.camel@perches.com>
Date: Thu, 21 Dec 2017 13:05:56 +0100
In-Reply-To: <1513030348.3036.5.camel@perches.com> (Joe Perches's message of
	"Mon, 11 Dec 2017 14:12:28 -0800")
Message-ID: <m337449tgb.fsf@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Dave Chinner <david@fromorbit.com>, Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

Joe Perches <joe@perches.com> writes:

> On Tue, 2017-12-12 at 08:43 +1100, Dave Chinner wrote:
>> On Sat, Dec 09, 2017 at 09:00:18AM -0800, Joe Perches wrote:
>> > On Sat, 2017-12-09 at 09:36 +1100, Dave Chinner wrote:
>> > > 	1. Using lockdep_set_novalidate_class() for anything other
>> > > 	than device->mutex will throw checkpatch warnings. Nice. (*)
>> > []
>> > > (*) checkpatch.pl is considered mostly harmful round here, too,
>> > > but that's another rant....
>> > 
>> > How so?
>> 
>> Short story is that it barfs all over the slightly non-standard
>> coding style used in XFS.
> []
>> This sort of stuff is just lowest-common-denominator noise - great
>> for new code and/or inexperienced developers, but not for working
>> with large bodies of existing code with slightly non-standard
>> conventions.
>
> Completely reasonable.  Thanks.
>
> Do you get many checkpatch submitters for fs/xfs?
>
> If so, could probably do something about adding
> a checkpatch file flag to the directory or equivalent.
>
> Maybe add something like:
>
> fs/xfs/.checkpatch
>
> where the contents turn off most everything

I propose a more fine grained and configurable form of this in

   https://lkml.org/lkml/2017/12/16/343

that also handles sparse and other checkers in a similar way.

Thanks,
Knut

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
