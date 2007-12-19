Date: Wed, 19 Dec 2007 11:31:07 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Message-ID: <20071219113107.5301f9f0@cuia.boston.redhat.com>
In-Reply-To: <1198079529.5333.12.camel@localhost>
References: <20071218211539.250334036@redhat.com>
	<20071218211548.784184591@redhat.com>
	<200712191148.06506.nickpiggin@yahoo.com.au>
	<1198079529.5333.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007 10:52:09 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> I keep these patches up to date for testing.  I don't have conclusive
> evidence whether they alleviate or exacerbate the problem nor by how
> much.  

When the queued locking from Ingo's x86 tree hits mainline,
I suspect that spinlocks may end up behaving a lot nicer.

Should I drop the rwlock patches from my tree for now and
focus on just the page reclaim stuff?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
