Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A05B06B0139
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:47:40 -0400 (EDT)
Date: Wed, 22 Jul 2009 17:47:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
Message-Id: <20090722174741.79743e3a.akpm@linux-foundation.org>
In-Reply-To: <20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
	<20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
	<20090722171245.d5b3a108.akpm@linux-foundation.org>
	<20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, hugh.dickins@tiscali.co.uk, avi@redhat.com, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 2009 09:33:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> BTW, when I post new version, should I send a reply to old version to say
> "this version is obsolete" ? Can it make your work easier ? like following.
> 
> Re:[PATCH][Obsolete] new version weill come (Was.....)
> 
> I tend to update patches until v5 or more until merged.

Usually it's pretty clear when a new patch or patch series is going to
be sent.  I think that simply resending it all is OK.

I don't pay much attention to the "version N" info either - it can be
unreliable and not everyone does it and chronological ordering works OK
for this.

Very occasionally I'll merge a patch and then discover a later version
further down through the backlog.  But that's OK - I'll just update the
patch.  Plus I'm not usually stuck this far in the past.

(I'm still trying to find half a day to read "Per-bdi writeback flusher
threads v12")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
