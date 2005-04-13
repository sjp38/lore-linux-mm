Message-ID: <425C7876.9050302@yahoo.com.au>
Date: Wed, 13 Apr 2005 11:40:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/4] pcp: zonequeues
References: <4257D74C.3010703@yahoo.com.au> <Pine.LNX.4.58.0504121202060.7576@graphe.net>
In-Reply-To: <Pine.LNX.4.58.0504121202060.7576@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Seems that this also effectively addresses the issues raised with the
> pageset localization patches. Great work Nick!
> 

I'd be interested to know what performance and lock contention
looks like on your larger systems, because we're using lru_lock
for the remote pageset... and there's only one of them.

Your interleaved pagecache allocation policy should be a good
brute force benchmark - just have one or two processes on each
node allocating pagecache pages (eg. from reading huge sparse
files).

The other thing is, you may want to look at adjusting the
criteria for using the remote pageset. It might be helpful to
use per-cpu pagesets on near remote nodes...

Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
