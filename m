Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E33B6B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 07:13:48 -0400 (EDT)
Message-ID: <4DCBC0E8.5020609@cs.helsinki.fi>
Date: Thu, 12 May 2011 14:13:44 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Reduce impact to overall system of SLUB using high-order
 allocations
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>	 <1305149960.2606.53.camel@mulgrave.site>	 <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com> <1305153267.2606.57.camel@mulgrave.site>
In-Reply-To: <1305153267.2606.57.camel@mulgrave.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On 5/12/11 1:34 AM, James Bottomley wrote:
> On Wed, 2011-05-11 at 15:28 -0700, David Rientjes wrote:
>> On Wed, 11 May 2011, James Bottomley wrote:
>>
>>> OK, I confirm that I can't seem to break this one.  No hangs visible,
>>> even when loading up the system with firefox, evolution, the usual
>>> massive untar, X and even a distribution upgrade.
>>>
>>> You can add my tested-by
>>>
>> Your system still hangs with patches 1 and 2 only?
> Yes, but only once in all the testing.  With patches 1 and 2 the hang is
> much harder to reproduce, but it still seems to be present if I hit it
> hard enough.

Patches 1-2 look reasonable to me. I'm not completely convinced of patch 
3, though. Why are we seeing these problems now? This has been in 
mainline for a long time already. Shouldn't we fix kswapd?

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
