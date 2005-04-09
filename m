Message-ID: <4257D899.30102@yahoo.com.au>
Date: Sat, 09 Apr 2005 23:28:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/4] pcp: zonequeues
References: <4257D74C.3010703@yahoo.com.au>
In-Reply-To: <4257D74C.3010703@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Not tested (only compiled) on a NUMA system, but the NULL pagesets
> logic appears to work OK. Boots on a small UMA SMP system. So just
> be careful with it.
> 
> Comments?
> 

Oh, and you may want to look at increasing the pageset and batch
sizes if you look at running this on a bigger system. Now that
there are reduced pagesets, it might help improve lock contention
and allocation efficiency.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
