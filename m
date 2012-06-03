Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id DFD1A6B004D
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 14:23:51 -0400 (EDT)
Received: by wibhj6 with SMTP id hj6so1817770wib.8
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 11:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120603181548.GA306@redhat.com>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <20120603181548.GA306@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 3 Jun 2012 11:23:29 -0700
Message-ID: <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jun 3, 2012 at 11:15 AM, Dave Jones <davej@redhat.com> wrote:
>
> Things aren't happy with that patch at all.

Yeah, at this point I think we need to just revert the compaction changes.

Guys, what's the minimal set of commits to revert? That clearly buggy
"rescue_unmovable_pageblock()" function was introduced by commit
5ceb9ce6fe94, but is that actually involved with the particular bug?
That commit seems to revert cleanly still, but is that sufficient or
does it even matter?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
