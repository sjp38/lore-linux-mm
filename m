Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 72F8A6B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:45:06 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fl4so107760034pad.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 01:45:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ku4si46191856pab.153.2016.02.23.01.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 01:45:05 -0800 (PST)
Date: Tue, 23 Feb 2016 01:45:01 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223094501.GA32294@infradead.org>
References: <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <x49y4ac630l.fsf@segfault.boston.devel.redhat.com>
 <20160222180350.GA9866@infradead.org>
 <x49twl060ib.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49twl060ib.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 22, 2016 at 01:52:28PM -0500, Jeff Moyer wrote:
> I see.  So, at write fault time, you're saying that new blocks may be
> allocated, and that in order to make that persistent, we need a sync
> operation.

Yes.

> Presumably this MAP_SYNC option could sync out the necessary
> metadata updates to the log before returning from the write fault
> handler.  The arguments against making this work are that it isn't
> generally useful, and that we don't want more dax special cases in the
> code.  Did I get that right?

The argument is that it's non-trivial, and we haven't even sorted out
basic semantics for directly mapped storaged.  Let's finish up getting
this right, and then look into optimizing it further in the next step.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
