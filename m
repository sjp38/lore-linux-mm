Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C15136B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:54:29 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l7so137289836qtd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 06:54:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p132si16728998qka.274.2017.01.17.06.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 06:54:29 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
References: <20170114002008.GA25379@linux.intel.com>
	<20170114082621.GC10498@birch.djwong.org>
	<x49wpduzseu.fsf@dhcp-25-115.bos.redhat.com>
	<20170117015033.GD10498@birch.djwong.org>
	<20170117075735.GB19654@infradead.org>
Date: Tue, 17 Jan 2017 09:54:27 -0500
In-Reply-To: <20170117075735.GB19654@infradead.org> (Christoph Hellwig's
	message of "Mon, 16 Jan 2017 23:57:35 -0800")
Message-ID: <x49mvep4tzw.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Christoph Hellwig <hch@infradead.org> writes:

> On Mon, Jan 16, 2017 at 05:50:33PM -0800, Darrick J. Wong wrote:
>> I wouldn't consider it a barrier in general (since ext4 also prints
>> EXPERIMENTAL warnings for DAX), merely one for XFS.  I don't even think
>> it's that big of a hurdle -- afaict XFS ought to be able to achieve this
>> by modifying iomap_begin to allocate new pmem blocks, memcpy the
>> contents, and update the memory mappings.  I think.

Ah, I wasn't even thinking about non PMEM_IMMUTABLE usage.

> Yes, and I have a working prototype for that.  I'm just way to busy
> with lots of bugfixing at the moment but I plan to get to it in this
> merge window.  I also agree that we can't mark a feature as fully
> supported until it doesn't conflict with other features.

Fair enough.

> And I'm not going to get start on the PMEM_IMMUTABLE bullshit, please
> don't even go there folks, it's a dead end.

I spoke with Dave before the holidays, and he indicated that
PMEM_IMMUTABLE would be an acceptable solution to allowing applications
to flush data completely from userspace.  I know this subject has been
beaten to death, but would you mind just summarizing your opinion on
this one more time?  I'm guessing this will be something more easily
hashed out at LSF, though.

Thanks,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
