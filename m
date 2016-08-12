Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF596B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 19:19:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 93so2279033qtg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 16:19:54 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id m68si4401967wma.37.2016.08.12.16.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 16:19:48 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id i138so102923wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 16:19:47 -0700 (PDT)
Date: Sat, 13 Aug 2016 02:19:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2, 00/41] ext4: support of huge pages
Message-ID: <20160812231944.GA5260@node.shutemov.name>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160812203440.GD30280@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812203440.GD30280@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Fri, Aug 12, 2016 at 04:34:40PM -0400, Theodore Ts'o wrote:
> On Fri, Aug 12, 2016 at 09:37:43PM +0300, Kirill A. Shutemov wrote:
> > Here's stabilized version of my patchset which intended to bring huge pages
> > to ext4.
> 
> So this patch is more about mm level changes than it is about the file
> system, and I didn't see any comments from the linux-mm peanut gallery
> (unless the linux-ext4 list got removed from the cc list, or some such).
> 
> I haven't had time to take a close look at the ext4 changes, and I'll
> try to carve out some time to do that

I would appreciate it.

> --- but has anyone from the mm
> side of the world taken a look at these patches?

Not yet. I had hard time obtaining review on similar-sized patchsets
before :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
