Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 184F96B02A6
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:24:50 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so43526529wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:24:50 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id z80si2035452wmd.57.2016.11.29.03.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:24:49 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so23711644wmu.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:24:48 -0800 (PST)
Date: Tue, 29 Nov 2016 14:24:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 00/33] Radix tree patches for 4.10
Message-ID: <20161129112446.GA8837@node.shutemov.name>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Nov 28, 2016 at 01:50:04PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Hi Andrew,
> 
> Please include these patches in the -mm tree for 4.10.  Mostly these
> are improvements; the only bug fixes in here relate to multiorder
> entries (which are unused in the 4.9 tree).  The IDR rewrite has the
> highest potential for causing mayhem as the test suite is quite spartan.
> We have an Outreachy intern scheduled to work on the test suite for the
> 2016 winter season, so hopefully it will improve soon.
> 
> I did not include Konstantin's suggested change to the API for
> radix_tree_iter_resume().  Many of the callers do not currently care
> about the size of the entry they are consuming, and determining that
> information is not always trivial.  Since this is not a performance
> critical API (it's called when we've paused iterating through a tree
> in order to schedule for a higher priority task), I think it's more
> important to have a simpler interface.
> 
> I'd like to thank Kiryl for all the testing he's been doing.  He's found
> at least two bugs which weren't related to the API extensions that he
> really wanted from this patch set.

Tested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I would like to get in as my ext4 patchset depends on this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
