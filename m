Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 11ADD6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 22:12:26 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q4so360819oic.12
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 19:12:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o42sor3675694oth.126.2017.10.10.19.12.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 19:12:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011004631.GX3666@dastard>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150764695771.16882.9179160793491582514.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171011004631.GX3666@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 19:12:23 -0700
Message-ID: <CAPcyv4jK9-otfgtyoq_9i+jDzdzYpBRTk0s5UqM8zMOMC09CXw@mail.gmail.com>
Subject: Re: [PATCH v8 04/14] xfs: prepare xfs_break_layouts() for reuse with MAP_DIRECT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Tue, Oct 10, 2017 at 5:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Tue, Oct 10, 2017 at 07:49:17AM -0700, Dan Williams wrote:
>> Move xfs_break_layouts() to its own compilation unit so that it can be
>> used for both pnfs layouts and MAP_DIRECT mappings.
> .....
>> diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
>> index b587cb99b2b7..4135b2482697 100644
>> --- a/fs/xfs/xfs_pnfs.h
>> +++ b/fs/xfs/xfs_pnfs.h
>> @@ -1,19 +1,13 @@
>>  #ifndef _XFS_PNFS_H
>>  #define _XFS_PNFS_H 1
>>
>> +#include "xfs_layout.h"
>> +
>
> I missed this the first time through - we try not to put includes
> in header files, and instead make sure each C file has all the
> includes they require. Can you move this to all the C files that
> need layouts and remove the include of the xfs_pnfs.h include from
> them?

Sure, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
