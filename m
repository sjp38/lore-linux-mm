Date: Thu, 23 Mar 2006 09:24:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Lockless pagecache perhaps for 2.6.18?
Message-ID: <20060323082425.GA9237@elte.hu>
References: <20060323081100.GE26146@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060323081100.GE26146@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> Would there be any objection to having my lockless pagecache patches 
> merged into -mm, for a possible mainline merge after 2.6.17 (ie. if/ 
> when the mm hackers feel comfortable with it).

i'd love to see it tested more, and then merged. It's really nifty.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
