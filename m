Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D42A26B0085
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:50:20 -0500 (EST)
Date: Wed, 12 Dec 2012 13:50:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/8] page reclaim bits
Message-Id: <20121212135019.ffa417bc.akpm@linux-foundation.org>
In-Reply-To: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 12 Dec 2012 16:43:32 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> I had these in my queue and on test machines for a while, but they got
> deferred over and over, partly because of the kswapd issues.  I hope
> it's not too late for 3.8, they should be fairly straight forward.

um, that is rather late.

Let's review these promptly and thoroughly, please.  Then we can look
at squeaking at least the simple and/or observably-beneficial ones into
-rc1 or -rc2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
