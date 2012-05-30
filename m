Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2E7A16B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:41:27 -0400 (EDT)
Date: Wed, 30 May 2012 14:41:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/6] mempolicy: Kill all mempolicy sharing
In-Reply-To: <1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1205301439410.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, andi@firstfloor.org

On Wed, 30 May 2012, kosaki.motohiro@gmail.com wrote:

> refcount will be decreased even though was not increased whenever alloc_page_vma()
> is called. As you know, mere mbind(MPOL_MF_MOVE) calls alloc_page_vma().

Most of these issues are about memory migration and shared memory. If we
exempt shared memory from memory migration (after all that shared memory
has its own distinct memory policies already!) then a lot of these issues
wont arise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
