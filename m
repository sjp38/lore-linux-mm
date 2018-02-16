Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCB006B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:03:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h13so2051837wrc.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:03:45 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x13si7800673wrg.466.2018.02.16.10.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 10:03:44 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b76028c6-c755-8178-2dfc-81c7db1f8bed@infradead.org>
Date: Fri, 16 Feb 2018 10:02:53 -0800
MIME-Version: 1.0
In-Reply-To: <20180216160121.519788537@linux.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/16/2018 08:01 AM, Christoph Lameter wrote:
> Control over this feature is by writing to /proc/zoneinfo.
> 
> F.e. to ensure that 2000 16K pages stay available for jumbo
> frames do
> 
> 	echo "2=2000" >/proc/zoneinfo
> 
> or through the order=<page spec> on the kernel command line.
> F.e.
> 
> 	order=2=2000,4N2=500


Please document the the kernel command line option in
Documentation/admin-guide/kernel-parameters.txt.

I suppose that /proc/zoneinfo should be added somewhere in Documentation/vm/
but I'm not sure where that would be.

thanks,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
