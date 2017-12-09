Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D84AD6B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 12:00:29 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n3so4780408ioc.0
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 09:00:29 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0186.hostedemail.com. [216.40.44.186])
        by mx.google.com with ESMTPS id d189si3264868itg.40.2017.12.09.09.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Dec 2017 09:00:23 -0800 (PST)
Message-ID: <1512838818.26342.7.camel@perches.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
From: Joe Perches <joe@perches.com>
Date: Sat, 09 Dec 2017 09:00:18 -0800
In-Reply-To: <20171208223654.GP5858@dastard>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
	 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
	 <20171208223654.GP5858@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Alan Stern <stern@rowland.harvard.edu>
Cc: Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Sat, 2017-12-09 at 09:36 +1100, Dave Chinner wrote:
> 	1. Using lockdep_set_novalidate_class() for anything other
> 	than device->mutex will throw checkpatch warnings. Nice. (*)
[]
> (*) checkpatch.pl is considered mostly harmful round here, too,
> but that's another rant....

How so?

> (**) the frequent occurrence of "core code/devs aren't held to the
> same rules/standard as everyone else" is another rant I have stored
> up for a rainy day.

Yeah.  I wouldn't mind reading that one...

Rainy season is starting right about now here too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
