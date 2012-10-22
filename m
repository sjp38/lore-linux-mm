Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id A37416B0083
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 17:39:41 -0400 (EDT)
Date: Mon, 22 Oct 2012 14:39:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v6
Message-Id: <20121022143940.6bf8103f.akpm@linux-foundation.org>
In-Reply-To: <20121022132733.GQ16230@one.firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
	<CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
	<20121022132733.GQ16230@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Hillf Danton <dhillf@gmail.com>

On Mon, 22 Oct 2012 15:27:33 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> BTW seriously MAP_UNINITIALIZED? Who came up with that? 
> MAP_COMPLETELY_INSECURE or MAP_INSANE would have been more appropiate.

heh.  It's a NOMMU-only thing.


config MMAP_ALLOW_UNINITIALIZED
	bool "Allow mmapped anonymous memory to be uninitialized"
	depends on EXPERT && !MMU
	default n
	help
	  Normally, and according to the Linux spec, anonymous memory obtained
	  from mmap() has it's contents cleared before it is passed to
	  userspace.  Enabling this config option allows you to request that
	  mmap() skip that if it is given an MAP_UNINITIALIZED flag, thus
	  providing a huge performance boost.  If this option is not enabled,
	  then the flag will be ignored.

	  This is taken advantage of by uClibc's malloc(), and also by
	  ELF-FDPIC binfmt's brk and stack allocator.

	  Because of the obvious security issues, this option should only be
	  enabled on embedded devices where you control what is run in
	  userspace.  Since that isn't generally a problem on no-MMU systems,
	  it is normally safe to say Y here.

	  See Documentation/nommu-mmap.txt for more information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
