Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5CE6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 05:04:39 -0400 (EDT)
Date: Tue, 17 Mar 2009 10:04:33 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH next] slob: fix build problem
Message-ID: <20090317090433.GE16952@elte.hu>
References: <20090317082549.GA5127@orion>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090317082549.GA5127@orion>
Sender: owner-linux-mm@kvack.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Alexander Beregalov <a.beregalov@gmail.com> wrote:

> mm/slob.c: In function '__kmalloc_node':
> mm/slob.c:480: error: 'flags' undeclared (first use in this function)
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

thanks, fixed it two days ago:

  bf722c9: lockdep: annotate reclaim context (__GFP_NOFS), fix SLOB

also posted on lkml.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
