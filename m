Date: Fri, 2 Mar 2007 17:18:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] free swap space of (re)activated pages
Message-Id: <20070302171818.d271348e.akpm@linux-foundation.org>
In-Reply-To: <45E88997.4050308@redhat.com>
References: <45E88997.4050308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 02 Mar 2007 15:31:19 -0500
Rik van Riel <riel@redhat.com> wrote:

> the attached patch frees the swap space of already resident pages
> when swap space starts getting tight, instead of only freeing up
> the swap space taken up by newly swapped in pages.
> 
> This should result in the swap space of pages that remain resident
> in memory being freed, allowing kswapd more chances to actually swap
> a page out (instead of rotating it back onto the active list).

Fair enough.   How do we work out if this helps things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
