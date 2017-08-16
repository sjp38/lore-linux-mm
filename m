Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9C946B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 12:29:26 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c13so66270067ywa.2
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 09:29:26 -0700 (PDT)
Received: from mail-yw0-x22b.google.com (mail-yw0-x22b.google.com. [2607:f8b0:4002:c05::22b])
        by mx.google.com with ESMTPS id b14si331958ybm.114.2017.08.16.09.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 09:29:25 -0700 (PDT)
Received: by mail-yw0-x22b.google.com with SMTP id s143so25836450ywg.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 09:29:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816111244.uxx6kvbi3cn5clqd@node.shutemov.name>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150286946864.8837.17147962029964281564.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170816111244.uxx6kvbi3cn5clqd@node.shutemov.name>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Aug 2017 09:29:24 -0700
Message-ID: <CAPcyv4iFzbVMgEJen--QNnFH7uuU7PWCV6S9c3fPwDMrr3iZjA@mail.gmail.com>
Subject: Re: [PATCH v5 4/5] fs, xfs: introduce MAP_DIRECT for creating
 block-map-atomic file ranges
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Wed, Aug 16, 2017 at 4:12 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Aug 16, 2017 at 12:44:28AM -0700, Dan Williams wrote:
>> @@ -1411,6 +1422,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>>
>>                       /* fall through */
>>               case MAP_PRIVATE:
>> +                     if ((flags & (MAP_PRIVATE|MAP_DIRECT))
>> +                                     == (MAP_PRIVATE|MAP_DIRECT))
>> +                             return -EINVAL;
>
> We've already checked for MAP_PRIVATE in this codepath. Simple (flags &
> MAP_DIRECT) would be enough.

True, willl fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
