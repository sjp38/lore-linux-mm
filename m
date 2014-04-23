Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 70D186B003B
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:37:25 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so1215961qaq.36
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:37:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c4si929654qad.187.2014.04.23.11.37.24
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 11:37:24 -0700 (PDT)
Date: Wed, 23 Apr 2014 14:16:12 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15rc2 hanging processes on exit.
Message-ID: <20140423181612.GA10236@redhat.com>
References: <20140422180308.GA19038@redhat.com>
 <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
 <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
 <20140423144901.GA24220@redhat.com>
 <CA+55aFziPHmSP5yjxDP6h_hRY-H2VgWZKsqC7w8+B9d9wXqn6Q@mail.gmail.com>
 <alpine.LSU.2.11.1404231057470.2678@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404231057470.2678@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 23, 2014 at 11:11:53AM -0700, Hugh Dickins wrote:
 > > Very odd.  Does anybody see anything I missed?
 > 
 > Easily explained (correct me if I'm wrong): Dave is reporting this from
 > his testing of 3.14,

correct.

 > but Linus is looking at his 3.15-rc git tree, which now contains
 > 
 > commit 57e68e9cd65b4b8eb4045a1e0d0746458502554c
 > Author: Vlastimil Babka <vbabka@suse.cz>
 > Date:   Mon Apr 7 15:37:50 2014 -0700
 >     mm: try_to_unmap_cluster() should lock_page() before mlocking
 > 
 > precisely to fix this (long-standing but long-unnoticed) issue,
 > which Sasha reported a couple of months ago.

ah, great. as long as it's fixed, I'm happy :)

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
