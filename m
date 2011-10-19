Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9830F6B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 09:40:17 -0400 (EDT)
Received: by wyg34 with SMTP id 34so2312010wyg.14
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 06:40:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111019074336.GB3410@suse.de>
References: <201110122012.33767.pluto@agmk.net> <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils> <20111016235442.GB25266@redhat.com>
 <alpine.LSU.2.00.1110171111150.2545@sister.anvils> <20111019074336.GB3410@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 19 Oct 2011 06:39:55 -0700
Message-ID: <CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> My vote is with the migration change. While there are occasionally
> patches to make migration go faster, I don't consider it a hot path.
> mremap may be used intensively by JVMs so I'd loathe to hurt it.

Ok, everybody seems to like that more, and it removes code rather than
adds it, so I certainly prefer it too. Pawe=C5=82, can you test that other
patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
locking patch that you already verified for your setup?

Hugh - that one didn't have a changelog/sign-off, so if you could
write that up, and Pawe=C5=82's testing is successful, I can apply it...
Looks like we have acks from both Andrea and Mel.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
