Message-ID: <3AC4E593.1010909@missioncriticallinux.com>
Date: Fri, 30 Mar 2001 14:59:15 -0500
From: "Patrick O'Rourke" <orourke@missioncriticallinux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Reclaim orphaned swap pages
References: <20010328235958.A1724@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Tweedie wrote:

 
> The patch works completely differently to the release-on-exit diffs:
> this one works in refill_inactive(), so has zero impact on the hot
> paths.  It also works by looking for such orphaned pages in the swap
> cache, not by examining swap entries --- it is much cheaper to find
> a swap entry for a given page than to find the swap cache page for a
> given swap entry.

It seems we would still have the situation whereby a process will be unable
to allocate memory because vm_enough_memory() fails, even though there is
sufficient orphaned swap pages available to satisfy the request. Isn't it
possible there may be enough free memory such that refill_inactive_scan()
isn't running, but still not enough to satisfy vm_enough_memory()?

Pat

-- 
Patrick O'Rourke
978.606.0236
orourke@missioncriticallinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
