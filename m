Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 111F56B0256
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 15:25:53 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id y9so126850058qgd.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:25:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m81si27321607qhb.91.2016.02.29.12.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 12:25:52 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
	<x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
	<x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
	<20160224225623.GL14668@dastard>
	<x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
	<x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
	<20160225201517.GA30721@dastard>
	<x49io1cik45.fsf@segfault.boston.devel.redhat.com>
	<20160225222705.GD30721@dastard>
Date: Mon, 29 Feb 2016 15:25:49 -0500
Message-ID: <x497fhnl0vm.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi, Dave,

Dave Chinner <david@fromorbit.com> writes:

>> You're missing the point.  You can't take applications that don't know
>> how to deal with torn sectors and put them on a block device that does
>> not provide power fail write atomicity of a single sector.
>
> Very few applications actually care about atomic sector writes.

I agree that most applications do not care about power-fail write
atomicity of a single sector.  However, of those applications that do
care about it, how many will/can run safely when atomic sector writes
are not provided?  Thanu gave some examples of applications that require
atomic sector writes today, and I'm sure there are more.  It sounds like
you are comfortable with running those applications on a file system
layered on top of a raw pmem device.  (Again, I'm coming from the angle
that block storage already provides this guarantee, at least mostly.)

> IOWs, you've just pointed to an application that demonstrates
> pmem-safe behaviour - just configure the database files with
> "file:somefile.db?psow=0" and it will assume that individual sector
> writes can be torn, and it will always recover.
>
> Hence I'm not sure exactly what point you are trying to make with
> this example.

Sorry, what I meant to point out was that the sqlite developers changed
from assuming sectors could be torn to assuming they were not.  So, *by
default*, the database assumes that sectors will not be torn.

Dave, on one hand you're arguing fervently for data integrity (over
pre-mature optimisation).  But on the other hand you're willing to
ignore data integrity completely for a set of existing applications.
This is not internally consistent.  :)  Please explain.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
