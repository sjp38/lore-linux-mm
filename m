Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4D682F66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 13:35:04 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so35880765pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 10:35:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cz1si1902688pbc.92.2015.11.04.10.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 10:35:03 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
	<20151030035533.GU19199@dastard>
	<20151030183938.GC24643@linux.intel.com>
	<20151101232948.GF10656@dastard>
	<x49vb9kqy5k.fsf@segfault.boston.devel.redhat.com>
	<20151102201029.GI10656@dastard>
	<x49twp4p11j.fsf@segfault.boston.devel.redhat.com>
Date: Wed, 04 Nov 2015 13:34:58 -0500
In-Reply-To: <x49twp4p11j.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Mon, 02 Nov 2015 16:02:48 -0500")
Message-ID: <x49a8qtpq99.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-nvdimm@ml01.01.org, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, "H. Peter Anvin" <hpa@zytor.com>, Jeff Layton <jlayton@poochiereds.net>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, linux-ext4@vger.kernel.org, xfs@oss.sgi.com, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, axboe@kernel.dk, Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Jeff Moyer <jmoyer@redhat.com> writes:

>> Hence once the filesystem has waited on the REQ_WRITE|REQ_FLUSH IO
>> to complete, we know that all the earlier REQ_WRITE IOs are on
>> stable storage, too. Hence there's no need for the elevator to drain
>> the queue to guarantee completion ordering - the dispatch ordering
>> and flush/fua write semantics guarantee that when the flush/fua
>> completes, all the IOs dispatch prior to that flush/fua write are
>> also on stable storage...
>
> Des xfs rely on this model for correctness?  If so, I'd say we've got a
> problem.

Dave?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
