Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2DF6B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:15:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so350218242pgd.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:15:20 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b69si49231596pli.222.2016.12.13.12.15.18
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 12:15:19 -0800 (PST)
Date: Wed, 14 Dec 2016 07:15:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213201515.GB4326@dastard>
References: <20161213181511.GB2305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213181511.GB2305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 01:15:11PM -0500, Jerome Glisse wrote:
> I would like to discuss un-addressable device memory in the context of
> filesystem and block device. Specificaly how to handle write-back, read,
> ... when a filesystem page is migrated to device memory that CPU can not
> access.

You mean pmem that is DAX-capable that suddenly, without warning,
becomes non-DAX capable?

If you are not talking about pmem and DAX, then exactly what does
"when a filesystem page is migrated to device memory that CPU can
not access" mean? What "filesystem page" are we talking about that
can get migrated from main RAM to something the CPU can't access?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
