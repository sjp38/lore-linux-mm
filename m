Date: Wed, 6 Apr 2005 14:34:01 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: "orphaned pagecache memleak fix" question.
Message-Id: <20050406143401.3482ecd9.akpm@osdl.org>
In-Reply-To: <16980.20374.889089.242557@gargle.gargle.HOWL>
References: <16978.46735.644387.570159@gargle.gargle.HOWL>
	<20050406005804.0045faf9.akpm@osdl.org>
	<16979.53442.695822.909010@gargle.gargle.HOWL>
	<20050406122711.1875931a.akpm@osdl.org>
	<16980.20374.889089.242557@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrea@Suse.DE, linux-mm@kvack.org, Mason@Suse.COM
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>  > 
>  > Not for any deep reason: it's just that thus-far we've avoided fiddling
>  > witht he LRU queues in filesystems and it'd be nice to retain that.
> 
> What about do_invalidatepage() removing page from ->lru when
> ->invalidatepage() returns error?

That could be made to work, I guess.

It's a behavioural change though, which might result in really-hard-to-find
and slow memory leaks in filesystems which were previously working OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
