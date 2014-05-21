Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8E16B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:34:48 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so1695891pab.17
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:34:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id lp7si30407595pab.189.2014.05.21.12.34.47
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 12:34:48 -0700 (PDT)
Date: Wed, 21 May 2014 12:34:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: /prom/pid/clear_refs: avoid split_huge_page()
Message-Id: <20140521123446.ae45fa676cae27fffbd96cfd@linux-foundation.org>
In-Reply-To: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@intel.com>

On Wed, 21 May 2014 22:04:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Currently we split all THP pages on any clear_refs request. It's not
> necessary. We can handle this on PMD level.
> 
> One side effect is that soft dirty will potentially see more dirty
> memory, since we will mark whole THP page dirty at once.

This clashes pretty badly with
http://ozlabs.org/~akpm/mmots/broken-out/clear_refs-redefine-callback-functions-for-page-table-walker.patch

> Sanity checked with CRIU test suite. More testing is required.

Will you be doing that testing or was this a request for Cyrill & co to
help?

Perhaps this is post-3.15 material.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
