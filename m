Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E272C6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 15:43:44 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x8-v6so2752894qtc.15
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 12:43:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j51-v6si1423834qtf.239.2018.10.09.12.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 12:43:43 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
References: <20181002100531.GC4135@quack2.suse.cz>
Date: Tue, 09 Oct 2018 15:43:41 -0400
In-Reply-To: <20181002100531.GC4135@quack2.suse.cz> (Jan Kara's message of
	"Tue, 2 Oct 2018 12:05:31 +0200")
Message-ID: <x49woqqykgi.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Jan Kara <jack@suse.cz> writes:

> Hello,
>
> commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> mean time certain customer of ours started poking into /proc/<pid>/smaps
> and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> flags, the application just fails to start complaining that DAX support is
> missing in the kernel. The question now is how do we go about this?
>
> Strictly speaking, this is a userspace visible regression (as much as I
> think that application poking into VMA flags at this level is just too
> bold). Is there any precedens in handling similar issues with smaps which
> really exposes a lot of information that is dependent on kernel
> implementation details?
>
> I have attached a patch that is an obvious "fix" for the issue - just fake
> VM_MIXEDMAP flag in smaps. But I'm open to other suggestions...

Hi, Jan,

I'm intrigued by the use case.  Do I understand you correctly that the
database in question does not intend to make data persistent from
userspace?  In other words, fsync/msync system calls are being issued by
the database?

I guess what I'm really after is a statement of requirements or
expectations.  It would be great if you could convince the database
developer to engage in this discussion directly.

Cheers,
Jeff
