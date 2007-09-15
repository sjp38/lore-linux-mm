Message-ID: <46EB3CC0.7070301@redhat.com>
Date: Fri, 14 Sep 2007 22:00:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon() function
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205425.6536.69946.sendpatchset@localhost>
In-Reply-To: <20070914205425.6536.69946.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC 03/14 Reclaim Scalability: Define page_anon() function
> 	to answer the question: is page backed by swap space?
> 
> Against:  2.6.23-rc4-mm1
> 
> Originally part of Rik van Riel's split-lru patch.  Extracted
> to make available for other, independent reclaim patches.

> Originally posted, but not Signed-off-by:  Rik van Riel <riel@redhat.com>
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Here it is:

Signed-off-by: Rik van Riel <riel@redhat.com>

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
