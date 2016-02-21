Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C1FEE6B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 15:24:11 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so132335142wme.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 12:24:11 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id da7si33369273wjb.185.2016.02.21.12.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 12:24:10 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so132334801wme.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 12:24:10 -0800 (PST)
Message-ID: <56CA1CE7.6050309@plexistor.com>
Date: Sun, 21 Feb 2016 22:24:07 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com> <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
In-Reply-To: <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On 02/21/2016 09:51 PM, Dan Williams wrote:
<>
>> Please advise?
> 
> When this came up a couple weeks ago [1], the conclusion I came away
> with is 

I think I saw that talk, no this was not suggested. What was suggested
was an FS / mount knob. That would break semantics, this here does not
break anything.

> that if an application wants to avoid the overhead of DAX
> semantics it needs to use an alternative to DAX access methods.  Maybe
> a new pmem aware fs like Nova [2], or some other mechanism that
> bypasses the semantics that existing applications on top of ext4 and
> xfs expect.
> 

But my suggestion does not break any "existing applications" and does
not break any semantics of ext4 or xfs. (That I can see)

As I said above it perfectly co exists with existing applications and
is the best of both worlds. The both applications can write to the
same page and will not break any of application's expectation. Old or
new.

Please point me to where I'm wrong in the code submitted?

Besides even an FS like Nova will need a flag per vma like this,
it will need to sort out the different type of application. So
here is how this is communicated, on the mmap call, how else?
And also works for xfs or ext4

Do you not see how this is entirely different then what was
proposed? or am I totally missing something? Again please show
me how this breaks anything's expectations.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
