Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DDB8B6B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 11:18:11 -0400 (EDT)
Received: by wibz8 with SMTP id z8so69770535wib.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 08:18:11 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id d7si18318320wjb.4.2015.09.02.08.18.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 08:18:10 -0700 (PDT)
Received: by wicmc4 with SMTP id mc4so69913495wic.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 08:18:10 -0700 (PDT)
Message-ID: <55E7132E.104@plexistor.com>
Date: Wed, 02 Sep 2015 18:18:06 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901070608.GA5482@lst.de> <20150901222120.GQ3902@dastard> <20150902031945.GA8916@linux.intel.com> <20150902051711.GS3902@dastard> <55E6CF15.4070105@plexistor.com> <55E70653.4090302@linux.intel.com>
In-Reply-To: <55E70653.4090302@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On 09/02/2015 05:23 PM, Dave Hansen wrote:
<>
> I'd be curious what the cost is in practice.  Do you have any actual
> numbers of the cost of doing it this way?
> 
> Even if the instruction is a "noop", I'd really expect the overhead to
> really add up for a tens-of-gigabytes mapping, no matter how much the
> CPU optimizes it.

What tens-of-gigabytes mapping? I have yet to encounter an application
that does that. Our tests show that usually the mmaps are small.

I can send you a micro benchmark results of an mmap vs direct-io random
write. Our code will jump over holes in the file BTW, but I'll ask to also
run it with falloc that will make all blocks allocated.

Give me a few days to collect this.

I guess one optimization we should do is jump over holes and zero-extents.
This will save the case of a mostly sparse very big file.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
