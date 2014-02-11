Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DB4C96B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 18:58:21 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so7850797pdb.10
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:58:21 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q6si20506506pbf.334.2014.02.11.15.58.20
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 15:58:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+55aFx+-ynTnj2ycq6JFo56bo978n6ZjB6LBue-jb0ipw1tXg@mail.gmail.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
 <CA+55aFx+-ynTnj2ycq6JFo56bo978n6ZjB6LBue-jb0ipw1tXg@mail.gmail.com>
Subject: Re: [RFC, PATCH 0/2] mm: map few pages around fault address if they
 are in page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20140211235816.A2B50E0090@blue.fi.intel.com>
Date: Wed, 12 Feb 2014 01:58:16 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>

Linus Torvalds wrote:
> On Tue, Feb 11, 2014 at 1:39 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> > hm, we tried that a couple of times, many years ago.  Try
> > https://www.google.com/#q="faultahead" then spend a frustrating hour
> > trying to work out what went wrong.
> >
> > Of course, the implementation might have been poor and perhaps we can
> > get this to work.
> 
> Kirill's patch looks good, and shouldn't have much overhead, but the
> fact that it doesn't work is obviously something of a strike against
> it.. ;)
> 
> I don't see anything obviously wrong in it, although I think 32
> fault-around pages might be excessive (it uses stack space, and there
> are expenses wrt accounting and tear-down). But the patch is also
> against some odd kernel (presumably -mm) with lots of other changes,
> so I don't even know what it might be missing.

It's on top of v3.14-rc1 + __do_fault() claen up[1].

It's also on git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux fault_around/v1

[1] http://thread.gmane.org/gmane.linux.kernel.mm/113364

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
