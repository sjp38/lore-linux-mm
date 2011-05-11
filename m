Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC566B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:28:56 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4BMSrLn019674
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:28:53 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by wpaz37.hot.corp.google.com with ESMTP id p4BMSp4c029446
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:28:52 -0700
Received: by pvh1 with SMTP id 1so598774pvh.31
        for <linux-mm@kvack.org>; Wed, 11 May 2011 15:28:51 -0700 (PDT)
Date: Wed, 11 May 2011 15:28:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] Reduce impact to overall system of SLUB using
 high-order allocations
In-Reply-To: <1305149960.2606.53.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305149960.2606.53.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 11 May 2011, James Bottomley wrote:

> OK, I confirm that I can't seem to break this one.  No hangs visible,
> even when loading up the system with firefox, evolution, the usual
> massive untar, X and even a distribution upgrade.
> 
> You can add my tested-by
> 

Your system still hangs with patches 1 and 2 only?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
