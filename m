Date: Thu, 25 Mar 2004 23:23:40 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] RSS limit enforcement for 2.6
Message-ID: <20040325222340.GD2179@elf.ucw.cz>
References: <20040318220432.GB1505@openzaurus.ucw.cz> <Pine.LNX.4.44.0403250944250.11915-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0403250944250.11915-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > When running lingvistics computation, machine got completely
> > unusable due to bad memory pressure. nice -n 19 was
> > useless. Memory limit should help.
> 
> Is this with the new patch, with the old patch or
> without any RSS limiting patch ?

That was without any RSS limiting patch. I'm sorry, I have no time for
lingvistics just now.
								Pavel
-- 
When do you have a heart between your knees?
[Johanka's followup: and *two* hearts?]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
