Date: Sun, 16 Nov 2008 21:28:08 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
In-Reply-To: <49208E9A.5080801@redhat.com>
Message-ID: <Pine.LNX.4.64.0811162126550.17921@blonde.site>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20081115210039.537f59f5.akpm@linux-foundation.org>
 <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
 <49208E9A.5080801@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008, Rik van Riel wrote:
> 
> I wonder if the "do not do mark_page_accessed at page fault time"
> patch is triggering the current troublesome behaviour in the VM,
> because actively used file pages are not moved out of the way of
> the VM - which leads get_scan_ratio to believe that we are already
> hitting the working set on the file side and should also start
> scanning the anon LRUs.

That patch is only in the -mm tree, not in 2.6.28-rc.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
