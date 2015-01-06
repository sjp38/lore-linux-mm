Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADED6B00E4
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 13:30:03 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so50832wiw.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 10:30:03 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id wo6si58894957wjc.129.2015.01.06.10.30.02
        for <linux-mm@kvack.org>;
        Tue, 06 Jan 2015 10:30:02 -0800 (PST)
Date: Tue, 6 Jan 2015 20:29:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Message-ID: <20150106182954.GA30484@node.dhcp.inet.fi>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
 <54AC1ED5.2050101@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54AC1ED5.2050101@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org

On Tue, Jan 06, 2015 at 06:43:49PM +0100, Vlastimil Babka wrote:
> On 01/05/2015 12:46 PM, Kirill A. Shutemov wrote:
> > The only caller is __free_one_page(). By the time we should have
> > page->flags to be cleared already:
> > 
> >  - for 0-order pages though PCP list:
> 
> Can there even be a 0-order compound page? I guess not, so this is just confusing?

No, it can't.

Since I propose the VM_BUG_ON(page->flags), I tried to make point that
flags are cleared by the point in any case.

> Otherwise it seems like you are right and it's a dead code to be removed. I
> tried to check history to see when it was actually needed, but seems it predates
> git.

Yeah. But we keep updating it...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
