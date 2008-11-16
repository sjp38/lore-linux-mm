Date: Sun, 16 Nov 2008 10:15:06 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm: evict streaming IO cache first
In-Reply-To: <20081115210039.537f59f5.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>


On Sat, 15 Nov 2008, Andrew Morton wrote:
> 
> Really, I think that the old approach of observing the scanner
> behaviour (rather than trying to predict it) was better.

That's generally true. Self-adjusting behaviour rather than a-priori rules 
would be much nicer. However, we apparently need to fix this some way. 
Anybody willing to re-introduce some of the old logic?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
