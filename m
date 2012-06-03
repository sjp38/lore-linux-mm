Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id ACA8F6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 18:30:14 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6662068pbb.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 15:30:14 -0700 (PDT)
Date: Sun, 3 Jun 2012 15:29:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <CA+55aFzjuPTBNGkMohmy+AzvvB9S_aEUOpG2nD-WjS9YGdQV0w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1206031521020.15445@eggly.anvils>
References: <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com> <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <20120603181548.GA306@redhat.com> <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com> <20120603183139.GA1061@redhat.com> <20120603205332.GA5412@redhat.com>
 <CA+55aFzjuPTBNGkMohmy+AzvvB9S_aEUOpG2nD-WjS9YGdQV0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 3 Jun 2012, Linus Torvalds wrote:
> On Sun, Jun 3, 2012 at 1:53 PM, Dave Jones <davej@redhat.com> wrote:
> >
> > running just over two hours with that commit reverted with no obvious ill effects so far.
> 
> And how quickly have you usually seen the problems? Would you have
> considered two ours "good" in your bisection thing?
> 
> Also, just to check: Hugh sent out a patch called "mm: fix warning in
> __set_page_dirty_nobuffers". Is that applied in your tree too, or did
> the __set_page_dirty_nobuffers() warning go away with just the revert?

That patch is good for fixing the __set_page_dirty_nobuffers() warning,
but it has no relevance to the list corruption Dave was also reporting,
nor vice versa.  The common factor there is just Dave.

And no disaster that the warning fix missed -rc1: it's only a WARN_ON_ONCE,
and nothing was wrong beyond the warning itself, just noise.

It's true that Dave's original bisection raised the doubt whether
that warning is coming from somewhere else too; but best guess at this
point is that something got mixed up, and we should only worry about
that if we see the warning again once the known fix is in.

Hugh

> 
> I'm just trying to figure out exactly what you are testing. When you
> said "test with that (and Hugh's last patch) backed out", the "and
> Hugh's last patch" part was a bit ambiguous. Do you mean the trial
> patch in this thread (backed out) or do you mean "*with* Hugh's patch
> for the __set_page_dirty_nobuffers() warning".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
