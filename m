Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A85606B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 09:51:53 -0400 (EDT)
Date: Tue, 17 May 2011 08:51:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
In-Reply-To: <20110517084227.GI5279@suse.de>
Message-ID: <alpine.DEB.2.00.1105170847550.11187@router.home>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com> <20110517084227.GI5279@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 17 May 2011, Mel Gorman wrote:

> entirely. Christoph wants to maintain historic behaviour of SLUB to
> maximise the number of high-order pages it uses and at the end of the
> day, which option performs better depends entirely on the workload
> and machine configuration.

That is not what I meant. I would like more higher order allocations to
succeed. That does not mean that slubs allocation methods and flags passed
have to stay the same. You can change the slub behavior if it helps.

I am just suspicious of compaction. If these mods are needed to reduce the
amount of higher order pages then compaction does not have the
beneficial effect that it should have. It does not actually
increase the available higher order pages. Fix that first.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
