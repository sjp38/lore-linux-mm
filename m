Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 94AF86B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:06:05 -0400 (EDT)
Date: Fri, 13 May 2011 11:05:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110513100556.GB3569@suse.de>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105120942050.24560@router.home>
 <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <1305215742.27848.40.camel@jaguar>
 <1305225467.2575.66.camel@mulgrave.site>
 <1305229447.2575.71.camel@mulgrave.site>
 <1305230652.2575.72.camel@mulgrave.site>
 <BANLkTindTdL9a4VxZk_AXrWLQf6QWqjz5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTindTdL9a4VxZk_AXrWLQf6QWqjz5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 13, 2011 at 09:16:24AM +0300, Pekka Enberg wrote:
> Hi,
> 
> On Thu, May 12, 2011 at 11:04 PM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> > Confirmed, I'm afraid ... I can trigger the problem with all three
> > patches under PREEMPT.  It's not a hang this time, it's just kswapd
> > taking 100% system time on 1 CPU and it won't calm down after I unload
> > the system.
> 
> OK, that's good to know. I'd still like to take patches 1-2, though. Mel?
> 

Wait for a V2 please. __GFP_REPEAT should also be removed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
