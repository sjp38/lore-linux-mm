Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 975BC6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 22:20:58 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id n128so109771949pfn.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 19:20:58 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n89si6199074pfb.138.2016.01.26.19.20.57
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 19:20:57 -0800 (PST)
Date: Tue, 26 Jan 2016 22:20:55 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 2/8] radix tree test harness
Message-ID: <20160127032055.GN2948@linux.intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453213533-6040-3-git-send-email-matthew.r.wilcox@intel.com>
 <20160126154438.c07554d49c14b57005b64319@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126154438.c07554d49c14b57005b64319@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 26, 2016 at 03:44:38PM -0800, Andrew Morton wrote:
> > diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
> > new file mode 120000
> > index 0000000..1e6f41f
> > --- /dev/null
> > +++ b/tools/testing/radix-tree/linux/radix-tree.h
> > @@ -0,0 +1 @@
> > +../../../../include/linux/radix-tree.h
> > \ No newline at end of file
> 
> glumpf.  My tools have always had trouble with symlinks - patch(1)
> seems to handle them OK but diff(1) screws things up.  I've had one go
> at using git to replace patch/diff but it was a fail.
> 
> Am presently too lazy to have attempt #2 so I think I'll just do
> 
> --- /dev/null
> +++ a/tools/testing/radix-tree/linux/radix-tree.h
> @@ -0,0 +1 @@
> +#include "../../../../include/linux/radix-tree.h"

Fine by me; I wasn't sure whether to do it as an include or a symlink.
I could have gone either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
