Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 112CF6B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:33:18 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id w8so5484445qac.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:33:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gq5si17490455qab.233.2014.04.22.13.33.17
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 13:33:17 -0700 (PDT)
Date: Tue, 22 Apr 2014 16:32:44 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15rc2 hanging processes on exit.
Message-ID: <20140422203244.GA30757@redhat.com>
References: <20140422180308.GA19038@redhat.com>
 <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
 <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 22, 2014 at 01:17:33PM -0700, Hugh Dickins wrote:
 
 > Your patch looks to me correct and to the point; but I agree that
 > we haven't made a relevant change there recently, so I suppose it
 > comes from a trinity improvement rather than a new bug in 3.15.
 > 
 > (Dave, do you have time to confirm that by running new trinity on 3.14?)

I can give it a shot.

I think perhaps a bigger reason why this might be only just turning up,
is that I now have an upper bound on the number of entries in an iovec
at 256 entries.  So now there's more chance that we'll generate an iovec
that a syscall can actually use instead of us running out of memory
trying to satisfy every entry and constructing a broken iovec struct if
we hit ENOMEM

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
