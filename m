Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id AF3286B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 18:52:05 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id lf12so6525428vcb.31
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:52:05 -0800 (PST)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id tj7si6588412vdc.124.2014.02.11.15.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 15:52:04 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jx11so6855758veb.10
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:52:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
Date: Tue, 11 Feb 2014 15:52:03 -0800
Message-ID: <CA+55aFx+-ynTnj2ycq6JFo56bo978n6ZjB6LBue-jb0ipw1tXg@mail.gmail.com>
Subject: Re: [RFC, PATCH 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>

On Tue, Feb 11, 2014 at 1:39 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> hm, we tried that a couple of times, many years ago.  Try
> https://www.google.com/#q="faultahead" then spend a frustrating hour
> trying to work out what went wrong.
>
> Of course, the implementation might have been poor and perhaps we can
> get this to work.

Kirill's patch looks good, and shouldn't have much overhead, but the
fact that it doesn't work is obviously something of a strike against
it.. ;)

I don't see anything obviously wrong in it, although I think 32
fault-around pages might be excessive (it uses stack space, and there
are expenses wrt accounting and tear-down). But the patch is also
against some odd kernel (presumably -mm) with lots of other changes,
so I don't even know what it might be missing.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
