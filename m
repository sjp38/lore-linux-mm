Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 84CA06B006C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:12:25 -0500 (EST)
Message-ID: <4EC3624B.4080805@redhat.com>
Date: Wed, 16 Nov 2011 15:12:11 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <20111116101846.5b017d1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111116101846.5b017d1e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

ao? 2011a1'11ae??16ae?JPY 09:18, KAMEZAWA Hiroyuki a??e??:
>
> Hmm.. Doesn't this duplicate shmem_getpage_gfp() ? Can't you split/share codes ?
>

Yeah, you are right... I will split the code.

Thanks for review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
