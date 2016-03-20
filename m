Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 127696B0282
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:34:12 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so238368997pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:34:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r18si4857171pfi.140.2016.03.20.12.34.11
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 12:34:11 -0700 (PDT)
Date: Sun, 20 Mar 2016 22:34:07 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160320193407.GB1907@black.fi.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
 <20160320190016.GD17997@ZenIV.linux.org.uk>
 <CA+55aFzHPXcQT8XXy7=PAvaaN9d6uzu9JYN0nrtSPYWmr+=bWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzHPXcQT8XXy7=PAvaaN9d6uzu9JYN0nrtSPYWmr+=bWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, Mar 20, 2016 at 12:13:47PM -0700, Linus Torvalds wrote:
> On Sun, Mar 20, 2016 at 12:00 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >>
> >> It doesn't help legibility or testing, so let's just do it in one big go.
> >
> > Might make sense splitting it by the thing being removed, though - easier
> > to visually verify that it's doing the right thing when all replacements
> > are of the same sort...
> 
> Yeah, that might indeed make each patch easier to read, and if
> something goes wrong (which looks unlikely, but hey, shit happens), it
> also makes it easier to see just what went wrong.

Hm. Okay. Re-split this way would take some time. I'll post updated
patchset tomorrow.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
