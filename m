Message-ID: <4321A8EE.9080206@yahoo.com.au>
Date: Sat, 10 Sep 2005 01:23:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 7/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au> <4317F136.4040601@yahoo.com.au> <4317F17F.5050306@yahoo.com.au> <4317F1A2.8030605@yahoo.com.au> <4317F1BD.8060808@yahoo.com.au> <4317F1E2.7030608@yahoo.com.au> <4317F203.7060109@yahoo.com.au> <Pine.LNX.4.62.0509090549110.7332@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509090549110.7332@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> For Itanium (and I guess also for ppc64 and sparch64) the performance of 
> write_lock/unlock is the same as spin_lock/unlock. There is at least 
> one case where concurrent reads would be allowed without this patch. 
> 

Yep, I picked up another one that was easy to make lockless (I'll send
out a new patchset soon), however the tagged lookup that was under read
lock is changed to a spin lock.

It shouldn't be too difficult to make the tag lookups (find_get_pages_tag)
lockless, however I just haven't gotten around to looking at the write
side of the tagging yet.

When that is done, there should be no more read locks at all.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
