Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 48D906B007E
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 10:01:36 -0400 (EDT)
Date: Tue, 19 Jul 2011 09:01:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <alpine.DEB.2.00.1107181651000.31576@router.home>
Message-ID: <alpine.DEB.2.00.1107190901120.1199@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1107180951390.30392@router.home> <20110718160552.GB5349@suse.de> <alpine.DEB.2.00.1107181208050.31576@router.home>
 <20110718211325.GC5349@suse.de> <alpine.DEB.2.00.1107181651000.31576@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Well we can unwind that complexity later I guess.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
