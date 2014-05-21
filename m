Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 00AEB6B0038
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:19:18 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id mc6so1946157lab.35
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:19:18 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id wf8si8526588lbb.47.2014.05.21.12.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 12:19:17 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so1898827lbd.36
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:19:17 -0700 (PDT)
Date: Wed, 21 May 2014 23:19:15 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: /prom/pid/clear_refs: avoid split_huge_page()
Message-ID: <20140521191915.GC12819@moon>
References: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, May 21, 2014 at 10:04:22PM +0300, Kirill A. Shutemov wrote:
> Currently we split all THP pages on any clear_refs request. It's not
> necessary. We can handle this on PMD level.
> 
> One side effect is that soft dirty will potentially see more dirty
> memory, since we will mark whole THP page dirty at once.
> 
> Sanity checked with CRIU test suite. More testing is required.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Dave Hansen <dave.hansen@intel.com>

Looks reasonable to me, thanks!

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
