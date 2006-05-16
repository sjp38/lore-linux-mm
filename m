Date: Tue, 16 May 2006 09:00:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: cleanup swap unused warning
In-Reply-To: <200605162314.36059.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.64.0605160859230.6065@schroedinger.engr.sgi.com>
References: <200605102132.41217.kernel@kolivas.org>
 <Pine.LNX.4.64.0605101604330.7472@schroedinger.engr.sgi.com>
 <200605162055.36957.kernel@kolivas.org> <200605162314.36059.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 May 2006, Con Kolivas wrote:

> The variable is not compiled in so the empty static inline as suggested by
> Pekka suffices to silence this warning.

Maybe you could redo the whole thing? Is it a problem to make all the 
similar functions inlines?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
