Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB646B0005
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 19:45:59 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n5so242957466pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 16:45:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s4si6263790pfi.81.2016.03.20.16.45.58
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 16:45:58 -0700 (PDT)
Date: Sun, 20 Mar 2016 19:46:33 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 69/71] vfs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160320234633.GM23727@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-70-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458499278-1516-70-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org


Spotted an oops:

-       length is PAGE_CACHE_SIZE, then the private data should be released,
+       length is PAG__SIZE, then the private data should be released,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
