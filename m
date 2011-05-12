Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6AB44900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:03:11 -0400 (EDT)
Date: Thu, 12 May 2011 13:03:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <20110512175104.GM11579@random.random>
Message-ID: <alpine.DEB.2.00.1105121302240.28493@router.home>
References: <alpine.DEB.2.00.1105120942050.24560@router.home> <1305213359.2575.46.camel@mulgrave.site> <alpine.DEB.2.00.1105121024350.26013@router.home> <1305214993.2575.50.camel@mulgrave.site> <20110512154649.GB4559@redhat.com> <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home> <1305217843.2575.57.camel@mulgrave.site> <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com> <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com> <20110512175104.GM11579@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 12 May 2011, Andrea Arcangeli wrote:

> even order 3 is causing troubles (which doesn't immediately make lumpy
> activated, it only activates when priority is < DEF_PRIORITY-2, so
> after 2 loops failing to reclaim nr_to_reclaim pages), imagine what

That is a significant change for SLUB with the merge of the compaction
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
