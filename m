Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id C95A46B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 05:16:35 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so3417220eek.21
        for <linux-mm@kvack.org>; Fri, 23 May 2014 02:16:35 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id r10si5327022eev.73.2014.05.23.02.16.33
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 02:16:34 -0700 (PDT)
Date: Fri, 23 May 2014 12:16:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
Message-ID: <20140523091631.GA4400@node.dhcp.inet.fi>
References: <20140522135828.GA24879@redhat.com>
 <537ECCDB.8080009@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537ECCDB.8080009@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, May 23, 2014 at 12:21:47AM -0400, Sasha Levin wrote:
> On 05/22/2014 09:58 AM, Dave Jones wrote:
> > Not sure if Sasha has already reported this on -next (It's getting hard
> > to keep track of all the VM bugs he's been finding), but I hit this overnight
> > on .15-rc6.  First time I've seen this one.
> 
> Unfortunately I had to disable transhuge/hugetlb in my testing .config since
> the open issues in -next get hit pretty often, and were unfixed for a while
> now.

What THP-related is not fixed by now? collapse hung? what else?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
