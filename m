Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5337A6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 14:31:30 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so1497917pbc.3
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:31:30 -0700 (PDT)
Date: Thu, 26 Sep 2013 11:30:22 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130926183022.GN30372@lenny.home.zabbo.net>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130924234950.GC2018@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924234950.GC2018@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

> > Sigh.  A pox on whoever thought up huge pages. 
> 
> managing 1TB+ of memory in 4K chunks is just insane.
> The question of larger pages is not "if", but only "when".

And "how"!

Sprinking a bunch of magical if (thp) {} else {} throughtout the code
looks like a stunningly bad idea to me.  It'd take real work to
restructure the code such that the current paths are a degenerate case
of the larger thp page case, but that's the work that needs doing in my
estimation.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
