Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 07BA46B0005
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 18:21:37 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id u190so242134563pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:21:37 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id r74si17742887pfa.134.2016.03.20.15.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 15:21:36 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id n5so241335648pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:21:36 -0700 (PDT)
Date: Sun, 20 Mar 2016 15:21:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
In-Reply-To: <CA+55aFy+XcZ8roVhLH2T6bMs9RpykavxFv09yw08yw+LbzDXYg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1603201503400.20523@eggly.anvils>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com> <1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com> <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com> <20160320190016.GD17997@ZenIV.linux.org.uk>
 <CA+55aFzHPXcQT8XXy7=PAvaaN9d6uzu9JYN0nrtSPYWmr+=bWA@mail.gmail.com> <20160320193407.GB1907@black.fi.intel.com> <CA+55aFy+XcZ8roVhLH2T6bMs9RpykavxFv09yw08yw+LbzDXYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, 20 Mar 2016, Linus Torvalds wrote:
> On Sun, Mar 20, 2016 at 12:34 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Hm. Okay. Re-split this way would take some time. I'll post updated
> > patchset tomorrow.
> 
> Oh, I was assuming this was automated with coccinelle or at least some
> simple shell scripting..
> 
> Generally, for things like this, automation really is great.
> 
> In fact, I like it when people attach the scripts to the commit
> message, further clarifying exactly what they did (even if the end
> result then often includes manual fixups for patterns that didn't
> _quite_ match, or where the automated script just generated ugly
> indentation or similar).

Fine by me to make these changes - once upon a time I had a better
grip than most of when and how to use PAGE_CACHE_blah; but have long
lost it, and agree with all those who find the imaginary distinction
now a drag.

Just a plea, which I expect you already intend, to apply these changes
either just before 4.6-rc1 or just before 4.7-rc1 (I think I'd opt for
4.6-rc1 myself), without any interim of days or months in linux-next,
where a period of divergence would be quite tiresome.  Holding back
Kirill's 71/71 until the coast is clear just a little later.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
