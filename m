Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 48DDB6B0071
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:00:39 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3044165pad.8
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:00:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zj6si620547pac.146.2014.02.27.14.00.25
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 14:00:37 -0800 (PST)
Message-ID: <530FB55F.2070106@linux.intel.com>
Date: Thu, 27 Feb 2014 13:59:59 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com> <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 02/27/2014 11:53 AM, Kirill A. Shutemov wrote:
> +#define FAULT_AROUND_ORDER 4
> +#define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
> +#define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)

Looking at the performance data made me think of this: do we really want
this to be static?  It seems like the kind of thing that will cause a
regression _somewhere_.

Also, the folks with larger base bage sizes probably don't want a
FAULT_AROUND_ORDER=4.  That's 1MB of fault-around for ppc64, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
