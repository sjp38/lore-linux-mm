Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BFABE6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:44:40 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so105162392pac.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:44:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q140si5016986pfq.49.2016.01.26.15.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:44:39 -0800 (PST)
Date: Tue, 26 Jan 2016 15:44:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/8] radix tree test harness
Message-Id: <20160126154438.c07554d49c14b57005b64319@linux-foundation.org>
In-Reply-To: <1453213533-6040-3-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
	<1453213533-6040-3-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Jan 2016 09:25:27 -0500 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> From: Matthew Wilcox <willy@linux.intel.com>
> 
> This code is mostly from Andrew Morton; tarball downloaded
> from http://ozlabs.org/~akpm/rtth.tar.gz with sha1sum
> 0ce679db9ec047296b5d1ff7a1dfaa03a7bef1bd
> 
> Some small modifications were necessary to the test harness to fix the
> build with the current Linux source code.
> 
> I also made minor modifications to automatically test the radix-tree.c
> and radix-tree.h files that are in the current source tree, as opposed
> to a copied and slightly modified version.  I am sure more could be
> done to tidy up the harness, as well as adding more tests.
> 
> ...
>
> diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
> new file mode 120000
> index 0000000..1e6f41f
> --- /dev/null
> +++ b/tools/testing/radix-tree/linux/radix-tree.h
> @@ -0,0 +1 @@
> +../../../../include/linux/radix-tree.h
> \ No newline at end of file

glumpf.  My tools have always had trouble with symlinks - patch(1)
seems to handle them OK but diff(1) screws things up.  I've had one go
at using git to replace patch/diff but it was a fail.

Am presently too lazy to have attempt #2 so I think I'll just do

--- /dev/null
+++ a/tools/testing/radix-tree/linux/radix-tree.h
@@ -0,0 +1 @@
+#include "../../../../include/linux/radix-tree.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
