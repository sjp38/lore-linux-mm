Date: Tue, 8 Jan 2008 17:36:34 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080108173634.5ed3b0d4@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0801081421530.4281@schroedinger.engr.sgi.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<Pine.LNX.4.64.0801081421530.4281@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008 14:22:38 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> It may be good to coordinate this with Andrea Arcangeli's OOM fixes.

Probably.  With the split LRU lists (and the noreclaim LRUs), we can
simplify the OOM test a lot:

If free + file_active + file_inactive <= zone->pages_high and swap
space is full, the system is doomed.  No need for guesswork.

> Also would it be possible to create generic functions that can move pages 
> in pagevecs to an arbitrary lru list?

What would you use those functions for?

Or am I simply misunderstanding your idea?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
