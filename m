Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 26A7F6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 19:13:35 -0400 (EDT)
Received: by wefh52 with SMTP id h52so3347022wef.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 16:13:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1206031459450.15427@eggly.anvils>
References: <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <20120603181548.GA306@redhat.com>
 <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com>
 <20120603183139.GA1061@redhat.com> <20120603205332.GA5412@redhat.com> <alpine.LSU.2.00.1206031459450.15427@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 3 Jun 2012 16:13:13 -0700
Message-ID: <CA+55aFz--XDSOConDoM2SO0Jpd78Dg4GsGP+Z0F+__JWz+6JoQ@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jun 3, 2012 at 3:17 PM, Hugh Dickins <hughd@google.com> wrote:
>
> But another strike against that commit: I tried fixing it up to use
> start_page instead of page at the end, with the worrying but safer
> locking I suggested at first, with a count of how many times it went
> there, and how many times it succeeded.

You can't use start_page anyway, it might not be a valid page. There's
a reson it does that "pfn_valid_within()", methinks.

Anyway, my current plan is to apply your "mm: fix warning in
__set_page_dirty_nobuffers" patch - even if it's just a harmless
WARN_ON_ONCE(), and revert 5ceb9ce6fe94. Sounds like Dave hit normally
hit his problem much before two hours, and it must be even longer now.

Ack on that plan?

        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
