Date: Mon, 12 Nov 2007 11:18:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] SLUB: killed the unused "end" variable
In-Reply-To: <1194886182-2330-1-git-send-email-crquan@gmail.com>
Message-ID: <Pine.LNX.4.64.0711121118100.26682@schroedinger.engr.sgi.com>
References: <1194886182-2330-1-git-send-email-crquan@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denis Cheng <crquan@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007, Denis Cheng wrote:

> Since the macro "for_each_object" introduced, the "end" variable becomes unused anymore.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
