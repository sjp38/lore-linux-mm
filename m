Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFEE46B01F6
	for <linux-mm@kvack.org>; Mon, 17 May 2010 06:34:38 -0400 (EDT)
Date: Mon, 17 May 2010 12:34:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3] Fix boot_pageset sharing issue for new populated
	zones of hotadded nodes
Message-ID: <20100517103434.GC20761@basil.fritz.box>
References: <4BF0FBB0.1080707@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BF0FBB0.1080707@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 17, 2010 at 04:17:52PM +0800, Haicheng Li wrote:
> In our recent cpu/memory hotadd testing, with multiple nodes hotadded,
> kernel easily panics under stress workload like kernel building.
>
> The root cause is that the new populated zones of hotadded nodes are
> sharing same per_cpu_pageset, i.e. boot strapping boot_pageset, which
> finally causes page state wrong.
>
> The following three patches will setup the pagesets for hotadded nodes
> with dynamically allocated per_cpu_pageset struct.

Patches look good, thanks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
