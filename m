Date: Mon, 7 Jan 2008 11:37:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 11] limit reclaim if enough pages have been freed
In-Reply-To: <30fd9dd17ca34a24f066.1199326156@v2.random>
Message-ID: <Pine.LNX.4.64.0801071135380.23617@schroedinger.engr.sgi.com>
References: <30fd9dd17ca34a24f066.1199326156@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> No need to wipe out an huge chunk of the cache.

Wiping out a larger chunk of the cache avoids triggering reclaim too 
frequently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
