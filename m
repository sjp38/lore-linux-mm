Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE5036B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:51:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a38-v6so6447006wra.10
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:51:37 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id w10-v6si3422380wrg.377.2018.04.19.13.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 13:51:36 -0700 (PDT)
Date: Thu, 19 Apr 2018 21:51:30 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419205130.GL30522@ZenIV.linux.org.uk>
References: <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <1524162667.2943.22.camel@kernel.org>
 <20180419193108.GA4981@redhat.com>
 <20180419195637.GA14024@bombadil.infradead.org>
 <20180419201502.GA11372@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419201502.GA11372@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 04:15:02PM -0400, Jerome Glisse wrote:

> Well like you pointed out what i really want is a 1:1 structure linking
> a device struct an a mm_struct. Given that this need to be cleanup when
> mm goes away hence tying this to mmu_notifier sounds like a better idea.
> 
> I am thinking of adding a hashtable to mmu_notifier_mm using file id for
> hash as this should be a good hash value for common cases. I only expect
> few drivers to need that (GPU drivers, RDMA). Today GPU drivers do have
> a hashtable inside their driver and they has on the mm struct pointer,
> i believe hash mmu_notifier_mm using file id will be better.

What _is_ "file id"?  If you are talking about file descriptors, you can
very well have several for the same opened file.  Moreover, you can
bloody well have it opened, then dup'ed, then original descriptor closed
and reused by another open...
