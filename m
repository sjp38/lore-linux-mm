Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id B6A406B00D3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 17:45:40 -0500 (EST)
Date: Thu, 6 Dec 2012 14:45:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
Message-Id: <20121206144534.23d26318.akpm@linux-foundation.org>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Fri,  7 Dec 2012 01:09:27 +0900
Joonsoo Kim <js1304@gmail.com> wrote:

> This patchset remove vm_struct list management after initializing vmalloc.
> Adding and removing an entry to vmlist is linear time complexity, so
> it is inefficient. If we maintain this list, overall time complexity of
> adding and removing area to vmalloc space is O(N), although we use
> rbtree for finding vacant place and it's time complexity is just O(logN).
> 
> And vmlist and vmlist_lock is used many places of outside of vmalloc.c.
> It is preferable that we hide this raw data structure and provide
> well-defined function for supporting them, because it makes that they
> cannot mistake when manipulating theses structure and it makes us easily
> maintain vmalloc layer.
> 
> I'm not sure that "7/8: makes vmlist only for kexec" is fine.
> Because it is related to userspace program.
> As far as I know, makedumpfile use kexec's output information and it only
> need first address of vmalloc layer. So my implementation reflect this
> fact, but I'm not sure. And now, I don't fully test this patchset.
> Basic operation work well, but I don't test kexec. So I send this
> patchset with 'RFC'.
> 
> Please let me know what I am missing.
> 
> This series based on v3.7-rc7 and on top of submitted patchset for ARM.
> 'introduce static_vm for ARM-specific static mapped area'
> https://lkml.org/lkml/2012/11/27/356
> But, running properly on x86 without ARM patchset.

This all looks rather nice, but not mergeable into anything at this
stage in the release cycle.

What are the implications of "on top of submitted patchset for ARM"? 
Does it depens on the ARM patches in any way, or it it independently
mergeable and testable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
