Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E85366B0005
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:26:32 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w184so2386367ita.0
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:32 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [69.252.207.38])
        by mx.google.com with ESMTPS id x8si10546954itf.15.2018.02.16.10.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 10:26:32 -0800 (PST)
Date: Fri, 16 Feb 2018 12:25:27 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <20180216170354.vpbuugzqsrrfc4js@two.firstfloor.org>
Message-ID: <alpine.DEB.2.20.1802161224530.11268@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <20180216170354.vpbuugzqsrrfc4js@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, 16 Feb 2018, Andi Kleen wrote:

> > First performance tests in a virtual enviroment show
> > a hackbench improvement by 6% just by increasing
> > the page size used by the page allocator to order 3.
>
> So why is hackbench improving? Is that just for kernel stacks?

Less stack overhead. The large the page size the less metadata need to be
handled. The freelists get larger and the chance of hitting the per cpu
freelist increases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
