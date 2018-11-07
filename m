Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 540786B0563
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:38:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so16356001pfn.20
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:38:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x11-v6si1767518pln.425.2018.11.07.12.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:38:42 -0800 (PST)
Date: Wed, 7 Nov 2018 12:38:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/sparse: add common helper to mark all memblocks
 present
Message-Id: <20181107123838.1b7234c98a87dec5a2b25e67@linux-foundation.org>
In-Reply-To: <b1cc442e-7314-4a8e-3eec-9adc200d7582@deltatee.com>
References: <20181107173859.24096-1-logang@deltatee.com>
	<20181107173859.24096-3-logang@deltatee.com>
	<20181107121207.62cb37cf58484b7cc80a8fd8@linux-foundation.org>
	<724be9bb-59b6-33f3-7b59-3ca644d59bf7@deltatee.com>
	<alpine.DEB.2.21.1811072125280.1666@nanos.tec.linutronix.de>
	<b1cc442e-7314-4a8e-3eec-9adc200d7582@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>

On Wed, 7 Nov 2018 13:36:34 -0700 Logan Gunthorpe <logang@deltatee.com> wrote:

> > Actually if both names suck, then there also is the option to rename both
> > instead of adding a comment to explain the suckage.
> 
> Ok, well, I wasn't expecting to take on a big rename like that as it
> would create a patch touching a bunch of arches and mm files... But if
> we can come to some agreement on a better name and someone is willing to
> take that patch without significant delay then I'd be happy to create
> the patch and add it to the start of my series.

Some other time ;)  Let's just get the missing documentation added for now?
