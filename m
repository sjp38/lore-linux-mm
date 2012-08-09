Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 75A8F6B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 16:31:45 -0400 (EDT)
Message-ID: <50241DC5.7090704@redhat.com>
Date: Thu, 09 Aug 2012 16:29:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by reclaim/compaction
 based on failures
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-3-git-send-email-mgorman@suse.de> <20120808014824.GB4247@bbox> <20120808075526.GI29814@suse.de> <20120808082738.GF4247@bbox> <20120808085112.GJ29814@suse.de> <20120808235127.GA17835@bbox> <20120809074949.GA12690@suse.de> <20120809082715.GA19802@bbox> <20120809092035.GD12690@suse.de>
In-Reply-To: <20120809092035.GD12690@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/09/2012 05:20 AM, Mel Gorman wrote:

> The intention is that an allocation can fail but each subsequent attempt will
> try harder until there is success. Each allocation request does a portion
> of the necessary work to spread the cost between multiple requests.

At some point we need to stop doing that work, though.

Otherwise we could end up back at the problem where
way too much memory gets evicted, and we get swap
storms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
