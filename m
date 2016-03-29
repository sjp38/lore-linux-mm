Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7576B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:38:33 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id fp4so23713910obb.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:38:33 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id vs6si88721oeb.22.2016.03.29.12.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 12:37:56 -0700 (PDT)
Received: by mail-ob0-x234.google.com with SMTP id m7so23066876obh.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:37:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1459277829.6412.3.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	<1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
	<CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
	<1458939796.5501.8.camel@intel.com>
	<CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
	<1459195288.15523.3.camel@intel.com>
	<CAPcyv4jFwh679arTNoUzLZpJCSoR+KhMdEmwqddCU1RWOrjD=Q@mail.gmail.com>
	<1459277829.6412.3.camel@intel.com>
Date: Tue, 29 Mar 2016 12:37:14 -0700
Message-ID: <CAPcyv4hcSz7zKXzW3ZtdFbgBLbe0J2oNR-QC2L83adsvU3siFw@mail.gmail.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling dax_clear_sectors
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Tue, Mar 29, 2016 at 11:57 AM, Verma, Vishal L
<vishal.l.verma@intel.com> wrote:
> On Mon, 2016-03-28 at 16:34 -0700, Dan Williams wrote:
>
> <>
>
>> Seems kind of sad to fail the fault due to a bad block when we were
>> going to zero it anyway, right?  I'm not seeing a compelling reason to
>> keep any zeroing in fs/dax.c.
>
> Agreed - but how do we do this? clear_pmem needs to be able to clear an
> arbitrary number of bytes, but to go through the driver, we'd need to
> send down a bio? If only the driver had an rw_bytes like interface that
> could be used by anyone... :)

I think we're ok because clear_pmem() will always happen on PAGE_SIZE,
or HPAGE_SIZE boundaries.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
