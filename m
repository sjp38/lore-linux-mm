Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A25606B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:07:16 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l7so140194079qtd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:07:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o78si16909883qka.48.2017.01.17.08.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 08:07:15 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
References: <20170114002008.GA25379@linux.intel.com>
	<20170114082621.GC10498@birch.djwong.org>
	<x49wpduzseu.fsf@dhcp-25-115.bos.redhat.com>
	<20170117015033.GD10498@birch.djwong.org>
	<20170117075735.GB19654@infradead.org>
	<x49mvep4tzw.fsf@segfault.boston.devel.redhat.com>
	<20170117150638.GA3747@infradead.org>
Date: Tue, 17 Jan 2017 11:07:14 -0500
In-Reply-To: <20170117150638.GA3747@infradead.org> (Christoph Hellwig's
	message of "Tue, 17 Jan 2017 07:06:38 -0800")
Message-ID: <x49r3411xhp.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Christoph Hellwig <hch@infradead.org> writes:

> On Tue, Jan 17, 2017 at 09:54:27AM -0500, Jeff Moyer wrote:
>> I spoke with Dave before the holidays, and he indicated that
>> PMEM_IMMUTABLE would be an acceptable solution to allowing applications
>> to flush data completely from userspace.  I know this subject has been
>> beaten to death, but would you mind just summarizing your opinion on
>> this one more time?  I'm guessing this will be something more easily
>> hashed out at LSF, though.
>
> Come up with a prototype that doesn't suck and allows all fs features to
> actually work.

OK, I'll take this to mean that PMEM_IMMUTABLE is a non-starter.
Perhaps synchronous page faults (or whatever you want to call it) would
work, but...

> And show an application that actually cares and shows benefits on
> publicly available real hardware.

This is the crux of the issue.

> Until then go away and stop wasting everyones time.

Fair enough.  It seems fairly likely that this sort of functionality
would provide a big benefit.  But I agree we should have a real-world
use case as proof.

Thanks,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
