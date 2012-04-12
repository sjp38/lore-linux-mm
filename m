Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3363A6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:06:49 -0400 (EDT)
Date: Thu, 12 Apr 2012 11:06:12 -0400
From: Bob Picco <bpicco@meloft.net>
Subject: Re: [PATCH -mm] remove swap token code
Message-ID: <20120412150612.GA12549@gw1>
References: <20120409113201.6dff571a@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120409113201.6dff571a@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

Rik van Riel wrote:	[Mon Apr 09 2012, 11:32:01AM EDT]
> The swap token code no longer fits in with the current VM model.
> It does not play well with cgroups or the better NUMA placement
> code in development, since we have only one swap token globally.
> 
> It also has the potential to mess with scalability of the system,
> by increasing the number of non-reclaimable pages on the active
> and inactive anon LRU lists.
> 
> Last but not least, the swap token code has been broken for a
> year without complaints.  This suggests we no longer have much
> use for it.
> 
> The days of sub-1G memory systems with heavy use of swap are
> over. If we ever need thrashing reducing code in the future,
> we will have to implement something that does scale.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Bob Picco <bpicco@meloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
