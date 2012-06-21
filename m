Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4DF2E6B00A5
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:04:08 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1ShdJ6-0002ZV-AS
	for linux-mm@kvack.org; Thu, 21 Jun 2012 11:04:04 +0200
Received: from 60.172.250.164 ([60.172.250.164])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 11:04:04 +0200
Received: from xiyou.wangcong by 60.172.250.164 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 11:04:04 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Date: Thu, 21 Jun 2012 09:03:53 +0000 (UTC)
Message-ID: <jruo1o$j9v$1@dough.gmane.org>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Thu, 21 Jun 2012 at 01:19 GMT, David Rientjes <rientjes@google.com> wrote:
>
> show_free_areas() is called by the oom killer, so we know two things: it 
> can be called potentially very deep in the callchain and current is out of 
> memory.  Both are killers for this patch since you're allocating 
> nodemask_t on the stack here which could cause an overflow and because you 
> can't easily fix that case with NODEMASK_ALLOC() since it allocates slab 
> with GFP_KERNEL when we we're oom, which would simply suppress vital 
> meminfo from being shown.
>

Adding a comment in the beginning of show_free_areas() would be nice,
to tell people not to allocate more memory either on stack or in heap.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
