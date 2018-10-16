Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD9FC6B0007
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 08:35:15 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id j63-v6so13929908qte.13
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:35:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k30-v6si5251543qtd.180.2018.10.16.05.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 05:35:15 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
References: <20181002100531.GC4135@quack2.suse.cz>
	<x49woqqykgi.fsf@segfault.boston.devel.redhat.com>
	<20181016082540.GA18918@quack2.suse.cz>
Date: Tue, 16 Oct 2018 08:35:00 -0400
In-Reply-To: <20181016082540.GA18918@quack2.suse.cz> (Jan Kara's message of
	"Tue, 16 Oct 2018 10:25:40 +0200")
Message-ID: <x49d0sahxxn.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Jan Kara <jack@suse.cz> writes:

> Hi Jeff,
>
> On Tue 09-10-18 15:43:41, Jeff Moyer wrote:
>> I'm intrigued by the use case.  Do I understand you correctly that the
>> database in question does not intend to make data persistent from
>> userspace?  In other words, fsync/msync system calls are being issued by
>> the database?
>
> Yes, at least at the initial stage, they use fsync / msync to persist data.

OK.

>> I guess what I'm really after is a statement of requirements or
>> expectations.  It would be great if you could convince the database
>> developer to engage in this discussion directly.
>
> So I talked to them and what they really look after is the control over the
> amount of memory needed by the kernel. And they are right that if your
> storage needs page cache, the amount of memory you need to set aside for the
> kernel is larger.

OK, thanks a lot for following up, Jan!

-Jeff
