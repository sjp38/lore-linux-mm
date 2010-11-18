Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECABC6B008A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 05:24:37 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oAIAOXhQ011125
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:24:33 -0800
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by kpbe17.cbf.corp.google.com with ESMTP id oAIAOTcA024215
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:24:32 -0800
Received: by qwf7 with SMTP id 7so63840qwf.33
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:24:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101118085921.GA11314@amd>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
Date: Thu, 18 Nov 2010 02:24:31 -0800
Message-ID: <AANLkTi=+S25eBw5+-bcFAwRLOH-LPh--Tg72rohZJvzX@mail.gmail.com>
Subject: Re: [PATCH] Pass priority to shrink_slab
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Ying Han <yinghan@google.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 12:59 AM, Nick Piggin <npiggin@kernel.dk> wrote:
> FWIW, we can just add this to the new shrinker API, and convert over
> the users who care about it, so it doesn't have to be done in a big
> patch.

I also don't like that adding a shrinker parameter requires trivial
changes in every place that defines a shrinker.

I was wondering, could we just add a new structure for shrinker
parameters ? Your proposal of having parallel 'old' and 'new' APIs
works if this is a one-time change, but seems awkward if we want to
add additional parameters later on...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
