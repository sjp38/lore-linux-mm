Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 676F26B02F3
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 12:35:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v104so9239801wrb.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 09:35:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i11si1884519wra.167.2017.06.09.09.35.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 09:35:28 -0700 (PDT)
Date: Fri, 9 Jun 2017 18:35:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 00/20] Speculative page faults
Message-ID: <20170609163520.GB9332@dhcp22.suse.cz>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170609150126.GI21764@dhcp22.suse.cz>
 <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On Fri 09-06-17 17:25:51, Laurent Dufour wrote:
[...]
> Thanks Michal for your feedback.
> 
> I mostly focused on this database workload since this is the one where
> we hit the mmap_sem bottleneck when running on big node. On my usual
> victim node, I checked for basic usage like kernel build time, but I
> agree that's clearly not enough.
> 
> I try to find details about the 'kbench' you mentioned, but I didn't get
> any valid entry.
> Would you please point me on this or any other bench tool you think will
> be useful here ?

Sorry I meant kernbech (aka parallel kernel build). Other highly threaded
workloads doing a lot of page faults and address space modification
would be good to see as well. I wish I could give you much more
comprehensive list but I am not very good at benchmarks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
