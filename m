Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BC6926B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:34:31 -0400 (EDT)
Subject: Re: [PATCH 0/3] Reduce impact to overall system of SLUB using
 high-order allocations
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305149960.2606.53.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 May 2011 17:34:27 -0500
Message-ID: <1305153267.2606.57.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 2011-05-11 at 15:28 -0700, David Rientjes wrote:
> On Wed, 11 May 2011, James Bottomley wrote:
> 
> > OK, I confirm that I can't seem to break this one.  No hangs visible,
> > even when loading up the system with firefox, evolution, the usual
> > massive untar, X and even a distribution upgrade.
> > 
> > You can add my tested-by
> > 
> 
> Your system still hangs with patches 1 and 2 only?

Yes, but only once in all the testing.  With patches 1 and 2 the hang is
much harder to reproduce, but it still seems to be present if I hit it
hard enough.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
