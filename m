Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3310E6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:06:13 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so1542426pbc.9
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:06:12 -0700 (PDT)
Date: Thu, 26 Sep 2013 12:05:56 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130926190556.GJ2018@tassilo.jf.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130924234950.GC2018@tassilo.jf.intel.com>
 <20130926183022.GN30372@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926183022.GN30372@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 26, 2013 at 11:30:22AM -0700, Zach Brown wrote:
> > > Sigh.  A pox on whoever thought up huge pages. 
> > 
> > managing 1TB+ of memory in 4K chunks is just insane.
> > The question of larger pages is not "if", but only "when".
> 
> And "how"!
> 
> Sprinking a bunch of magical if (thp) {} else {} throughtout the code
> looks like a stunningly bad idea to me.  It'd take real work to
> restructure the code such that the current paths are a degenerate case
> of the larger thp page case, but that's the work that needs doing in my
> estimation.

Sorry, but that is how all of large pages in the Linux VM works
(both THP and hugetlbfs) 

Yes it would be nice if small pages and large pages all ran
in a unified VM. But that's not how Linux is designed today.

Yes having a Pony would be nice too.

Back when huge pages were originally proposed Linus came
up with the "separate hugetlbfs VM" design and that is what were
stuck with today.

Asking for a whole scale VM redesign is just not realistic.

VM is always changing in baby steps. And the only 
known way to do that is to have if (thp) and if (hugetlbfs) .

-Andi 

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
