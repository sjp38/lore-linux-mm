Date: Fri, 8 Jun 2007 20:01:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070609015944.GL9380@v2.random>
Message-ID: <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random>
 <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2007, Andrea Arcangeli wrote:

> I'm sorry to inform you that the oom killing in current mainline has
> always been a global event not a per-node one, regardless of the fixes
> I just posted.

Wrong. The oom killling is a local event if we are in a constrained 
allocation. The allocating task is killed not a random task. That call to 
kill the allocating task should not set any global flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
