Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 751106B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 10:23:16 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: O_DIRECT on tmpfs (again)
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
	<alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
	<50B6830A.20308@oracle.com>
Date: Thu, 29 Nov 2012 10:23:13 -0500
In-Reply-To: <50B6830A.20308@oracle.com> (Dave Kleikamp's message of "Wed, 28
	Nov 2012 15:32:58 -0600")
Message-ID: <x498v9kwhzy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Dave Kleikamp <dave.kleikamp@oracle.com> writes:

>> Whilst I agree with every contradictory word I said back then ;)
>> my current position is to wait to see what happens with Shaggy's "loop:
>> Issue O_DIRECT aio using bio_vec" https://lkml.org/lkml/2012/11/22/847
>
> As the patches exist today, the loop driver will only make the aio calls
> if the underlying file defines a direct_IO address op since
> generic_file_read/write_iter() will call a_ops->direct_IO() when
> O_DIRECT is set. For tmpfs or any other filesystem that doesn't support
> O_DIRECT, the loop driver will continue to call the read() or write()
> method.

Hi, Hugh and Shaggy,

Thanks for your replies--it looks like we're back to square one.  I
think it would be trivial to add O_DIRECT support to tmpfs, but I'm not
convinced it's necessary.  Should we wait until bug reports start to
come in?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
