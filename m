Message-ID: <46EDDEB9.8050904@redhat.com>
Date: Sun, 16 Sep 2007 21:56:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 7/14] Reclaim Scalability: Non-reclaimable page statistics
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205444.6536.78981.sendpatchset@localhost>
In-Reply-To: <20070914205444.6536.78981.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:

> Note:  my tests indicate that NR_NORECLAIM and probably the
> other LRU stats aren't being maintained properly

Interesting, I have had the same suspicion when testing
my split LRU patch.  Somewhere something seems to be
going wrong...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
