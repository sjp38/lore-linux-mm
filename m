Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D41AA6B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 15:42:28 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9JJgLv7011882
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:42:21 -0700
Received: from iaen33 (iaen33.prod.google.com [10.12.165.33])
	by wpaz29.hot.corp.google.com with ESMTP id p9JJfqHV004767
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:42:20 -0700
Received: by iaen33 with SMTP id n33so4629503iae.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:42:19 -0700 (PDT)
Date: Wed, 19 Oct 2011 12:42:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
In-Reply-To: <CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1110191234570.6900@sister.anvils>
References: <201110122012.33767.pluto@agmk.net> <alpine.LSU.2.00.1110131547550.1346@sister.anvils> <alpine.LSU.2.00.1110131629530.1410@sister.anvils> <20111016235442.GB25266@redhat.com> <alpine.LSU.2.00.1110171111150.2545@sister.anvils> <20111019074336.GB3410@suse.de>
 <CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wed, 19 Oct 2011, Linus Torvalds wrote:
> On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > My vote is with the migration change. While there are occasionally
> > patches to make migration go faster, I don't consider it a hot path.
> > mremap may be used intensively by JVMs so I'd loathe to hurt it.
> 
> Ok, everybody seems to like that more, and it removes code rather than
> adds it, so I certainly prefer it too. Pawel, can you test that other
> patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
> locking patch that you already verified for your setup?
> 
> Hugh - that one didn't have a changelog/sign-off, so if you could
> write that up, and Pawel's testing is successful, I can apply it...
> Looks like we have acks from both Andrea and Mel.

Yes, I'm glad to have that input from Andrea and Mel, thank you.

Here we go.  I can't add a Tested-by since Pawel was reporting on the
alternative patch, but perhaps you'll be able to add that in later.

I may have read too much into Pawel's mail, but it sounded like he
would have expected an eponymous find_get_pages() lockup by now,
and was pleased that this patch appeared to have cured that.

I've spent quite a while trying to explain find_get_pages() lockup by
a missed migration entry, but I just don't see it: I don't expect this
(or the alternative) patch to do anything to fix that problem.  I won't
mind if it magically goes away, but I expect we'll need more info from
the debug patch I sent Justin a couple of days ago.

Ah, I'd better send the patch separately as
"[PATCH] mm: fix race between mremap and removing migration entry":
Pawel's "l" makes my old alpine setup choose quoted printable when
I reply to your mail.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
