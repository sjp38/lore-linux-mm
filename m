Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id DA32E6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 16:53:42 -0400 (EDT)
Date: Sun, 3 Jun 2012 16:53:32 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120603205332.GA5412@redhat.com>
References: <20120601023107.GA19445@redhat.com>
 <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161205.GA1918@redhat.com>
 <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils>
 <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
 <20120603181548.GA306@redhat.com>
 <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com>
 <20120603183139.GA1061@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120603183139.GA1061@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jun 03, 2012 at 02:31:39PM -0400, Dave Jones wrote:
 > On Sun, Jun 03, 2012 at 11:23:29AM -0700, Linus Torvalds wrote:
 >  > On Sun, Jun 3, 2012 at 11:15 AM, Dave Jones <davej@redhat.com> wrote:
 >  > >
 >  > > Things aren't happy with that patch at all.
 >  > 
 >  > Yeah, at this point I think we need to just revert the compaction changes.
 >  > 
 >  > Guys, what's the minimal set of commits to revert? That clearly buggy
 >  > "rescue_unmovable_pageblock()" function was introduced by commit
 >  > 5ceb9ce6fe94, but is that actually involved with the particular bug?
 >  > That commit seems to revert cleanly still, but is that sufficient or
 >  > does it even matter?
 > 
 > I'l rerun the test with that (and Hugh's last patch) backed out, and see
 > if that makes any difference.

running just over two hours with that commit reverted with no obvious ill effects so far.

	Dave 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
