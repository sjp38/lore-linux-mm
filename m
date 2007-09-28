Date: Fri, 28 Sep 2007 16:20:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: document tree_lock->zone.lock lockorder
Message-Id: <20070928162039.9311c1e3.akpm@linux-foundation.org>
In-Reply-To: <20070928155536.GC12538@wotan.suse.de>
References: <20070928155536.GC12538@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Sep 2007 17:55:36 +0200
Nick Piggin <npiggin@suse.de> wrote:

> If you won't take the patch to move allocation out from under tree_lock,

rofl@nick.  My memory of patches only extends back for the previous
10000 or so.  You'll need to put a tad more effort into telling us
what you're referring to, sorry.

> please apply this update to lock ordering comments.

no probs, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
