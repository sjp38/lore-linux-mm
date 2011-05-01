Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 82889900113
	for <linux-mm@kvack.org>; Sun,  1 May 2011 12:37:46 -0400 (EDT)
Received: by pwi10 with SMTP id 10so3194663pwi.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 09:37:45 -0700 (PDT)
Date: Mon, 2 May 2011 01:37:37 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110501163737.GB3204@barrios-desktop>
References: <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110501163542.GA3204@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Mon, May 02, 2011 at 01:35:42AM +0900, Minchan Kim wrote:
 
> Do you see my old patch? The patch want't incomplet but it's not bad for showing an idea.
                                     ^^^^^^^^^^^^^^^^
                              typo : wasn't complete
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
