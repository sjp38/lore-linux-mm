Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C59796B0055
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 07:01:08 -0400 (EDT)
Date: Tue, 1 Sep 2009 12:00:32 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [mmotm][BUG] free is bigger than presnet Re: mmotm 2009-08-27-16-51
 uploaded
In-Reply-To: <20090901191018.19a69696.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909011158080.17324@sister.anvils>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
 <20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0909011031140.13740@sister.anvils>
 <20090901185013.c86bd937.kamezawa.hiroyu@jp.fujitsu.com>
 <20090901191018.19a69696.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:
> 
> Sorry again, at continuing tests...thre are still..
> 
> MemTotal:       24421124 kB
> MemFree:        25158956 kB
> Buffers:            2264 kB
> Cached:            34936 kB
> SwapCached:         5140 kB
> 
> I wonder I miss something..

I've not been looking at /proc/meminfo: I'll do some stuff and see
if it goes wrong for me too, will let you know if so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
