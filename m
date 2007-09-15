Message-ID: <46EB3B7B.4060007@redhat.com>
Date: Fri, 14 Sep 2007 21:55:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page()
 to vmscan.c
References: <20070914205359.6536.98017.sendpatchset@localhost>	 <20070914205418.6536.5921.sendpatchset@localhost> <1189805699.5826.19.camel@lappy>
In-Reply-To: <1189805699.5826.19.camel@lappy>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> remarcable change is the dissapearance of get_page_unless_zero() in the
> new version.

That can't be right.  The get_page_unless_zero() test
removes a real SMP race.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
