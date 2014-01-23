Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id D015F6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:38:56 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id tq11so502333ieb.0
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 18:38:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n9si17283526iga.52.2014.01.22.18.38.54
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 18:38:55 -0800 (PST)
Date: Wed, 22 Jan 2014 21:21:47 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: mm: BUG: Bad rss-counter state
Message-ID: <20140123022147.GA3221@redhat.com>
References: <52E06B6F.90808@oracle.com>
 <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com>
 <20140123015241.GA947@redhat.com>
 <52E07B63.1070400@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E07B63.1070400@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: David Rientjes <rientjes@google.com>, khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 22, 2014 at 09:16:03PM -0500, Sasha Levin wrote:
 > On 01/22/2014 08:52 PM, Dave Jones wrote:
 > > Sasha, is this the current git tree version of Trinity ?
 > > (I'm wondering if yesterdays munmap changes might be tickling this bug).
 > 
 > Ah yes, my tree has the munmap patch from yesterday, which would explain why we
 > started seeing this issue just now.

So that change is basically allowing trinity to munmap just part of a prior mmap.
So it may do things like..

mmap   |--------------|

munmap |----XXX-------|

munmap |------XXX-----|

ie, it might try unmapping some pages more than once, and may even overlap prior munmaps.

until yesterdays change, it would only munmap the entire mmap.

There's no easy way to tell exactly what happened without a trinity log of course.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
