Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E3C8E6B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 10:15:04 -0400 (EDT)
Date: Fri, 1 Jun 2012 10:14:59 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120601141459.GC1732@redhat.com>
References: <20120530163317.GA13189@redhat.com>
 <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com>
 <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 01, 2012 at 01:44:44AM -0700, Hugh Dickins wrote:
 > So I'm wondering if your trinity fuzzer happens to succeed a lot more
 > often on madvise MADV_REMOVEs than fallocate FALLOC_FL_PUNCH_HOLEs, and
 > the bug you converged on is not in tmpfs, but in ext4 (or xfs? or ocfs2?),
 > which began to support MADV_REMOVE with that commit.

One more thing: I happened to see this during a kernel build last night
on another machine too, so it's not just fuzzing fallout. I'm surprised more
people aren't seeing it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
