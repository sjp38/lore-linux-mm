Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 345ED6B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:22:31 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id v14so197170145ykd.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:22:31 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id i129si65317743ywb.311.2016.01.05.10.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:22:30 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id k129so268084328yke.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:22:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160105181430.GC6462@linux.intel.com>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
	<20160105111358.GD2724@quack.suse.cz>
	<20160105171235.GB6462@linux.intel.com>
	<CAPcyv4jAAAtRc7GSOqDZixxpQfM4bzHtkwmrsjLJ0Bqba+0KRA@mail.gmail.com>
	<20160105181430.GC6462@linux.intel.com>
Date: Tue, 5 Jan 2016 10:22:30 -0800
Message-ID: <CAPcyv4hYsnHoSFOgTFDtPaQkOq_N=evsKJsKsVe2_HbRfu5j9Q@mail.gmail.com>
Subject: Re: [PATCH v6 4/7] dax: add support for fsync/msync
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Jan 5, 2016 at 10:14 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Tue, Jan 05, 2016 at 09:20:47AM -0800, Dan Williams wrote:
[..]
>> My concern is whether flushing potentially invalid virtual addresses
>> is problematic on some architectures.  Maybe it's just FUD, but it's
>> less work in my opinion to just revalidate the address versus auditing
>> each arch for this concern.
>
> I don't think that the addresses have the potential of being invalid from the
> driver's point of view - we are still holding a reference on the block queue
> via dax_map_atomic(), so we should be protected against races vs block device
> removal.  I think the only question is whether it is okay to flush an address
> that we know to be valid from the block device's point of view, but which the
> filesystem may have truncated from being allocated to our inode.
>
> Does that all make sense?

Yes, I was confusing which revalidation we were talking about.  As
long as the dax_map_atomic() is there I don't think we need any
further revalidation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
