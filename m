Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFD16B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 22:22:53 -0400 (EDT)
Date: Tue, 7 Jul 2009 19:27:45 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 3/4] get_user_pages READ fault handling special
 cases
In-Reply-To: <20090708103807.ae17396a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.01.0907071927150.3210@localhost.localdomain>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707165950.7a84145a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.01.0907070931340.3210@localhost.localdomain> <20090708090344.aa54a008.kamezawa.hiroyu@jp.fujitsu.com>
 <20090708103807.ae17396a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



On Wed, 8 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> Is there a special reason to have to account zero page as file_rss ?
> If not, pte_special() solution works well. (I think not necessary..)

I would suggest _not_ accounting the zero page. After all, it doesn't 
actually use any memory.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
