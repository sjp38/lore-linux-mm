Date: Thu, 25 Mar 2004 09:44:41 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] RSS limit enforcement for 2.6
In-Reply-To: <20040318220432.GB1505@openzaurus.ucw.cz>
Message-ID: <Pine.LNX.4.44.0403250944250.11915-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2004, Pavel Machek wrote:

> When running lingvistics computation, machine got completely
> unusable due to bad memory pressure. nice -n 19 was
> useless. Memory limit should help.

Is this with the new patch, with the old patch or
without any RSS limiting patch ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
