Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 677376B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 21:49:03 -0400 (EDT)
Date: Wed, 11 Apr 2012 03:48:55 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] remove swap token code
Message-ID: <20120411014855.GA1929@cmpxchg.org>
References: <20120409113201.6dff571a@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120409113201.6dff571a@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 09, 2012 at 11:32:01AM -0400, Rik van Riel wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
