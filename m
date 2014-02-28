Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D86D56B004D
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 19:19:14 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id n15so2227105lbi.13
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:19:13 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id x5si8291933lal.135.2014.02.27.16.19.12
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 16:19:12 -0800 (PST)
Date: Fri, 28 Feb 2014 02:18:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
Message-ID: <20140228001858.GC8034@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
 <530FB55F.2070106@linux.intel.com>
 <CA+55aFzUYTHXcVnZL0vTGRPh3oQ8qYGO9+Va1Ch3P1yX+9knDg@mail.gmail.com>
 <530FBD8F.7090304@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <530FBD8F.7090304@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, anton@samba.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Feb 27, 2014 at 02:34:55PM -0800, Dave Hansen wrote:
> Kirill's git test suite runs did show that it _can_ hurt in some cases.

And see last use-case for how much it can hurt. :)

It shouldn't differs much for the same *number* of pages between [u]archs
unless setup of the pte is significantly more expensive or page fault is
faster.

But of course, I can move FAULT_AROUND_PAGES to arch/x86/ and let
architecture mantainers to decide if they want the feature. ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
