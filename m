Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED7596B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 22:25:01 -0400 (EDT)
Date: Fri, 16 Oct 2009 03:24:57 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
In-Reply-To: <20091016102951.a4f66a19.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910160314310.2993@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150153560.3291@sister.anvils>
 <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0910160016160.11643@sister.anvils>
 <20091016102951.a4f66a19.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > 
> My concern is that small numbers of swap_map[] which has too much refcnt
> can consume too much pages.
> 
> If an entry is shared by 65535, 65535/128 = 512 page will be used.
> (I'm sorry if I don't undestand implementation correctly.)

Ah, you're thinking it's additive: perhaps because I use the name
"continuation", which may give that impression - maybe there's a
better name I can give it.

No, it's multiplicative - just like 999 is almost a thousand, not 27.

If an entry is shared by 65535, then it needs its original swap_map
page (0 to 0x3e) and a continuation page (0 to 0x7f) and another
continuation page (0 to 0x7f): if I've got my arithmetic right,
those three pages can hold a shared count up to 1032191, for
every one of that group of PAGE_SIZE neighbouring pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
