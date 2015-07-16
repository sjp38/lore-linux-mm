Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 16 Jul 2015 15:12:58 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [mmotm:master 140/321] fs/built-in.o:undefined reference to `filemap_page_mkwrite'
Message-ID: <20150716191258.GA22760@kvack.org>
References: <201507160919.VRGXvreQ%fengguang.wu@intel.com> <20150716190503.GA22146@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716190503.GA22146@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Jeff Moyer <jmoyer@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Jul 16, 2015 at 09:05:03PM +0200, Oleg Nesterov wrote:
> Thanks!
...
> but the problem looks clear: CONFIG_MMU is not set, so we need
> a dummy filemap_page_mkwrite() along with generic_file_mmap() and
> generic_file_readonly_mmap().
> 
> I'll send the fix, but...
> 
> Benjamin, Jeff, shouldn't AIO depend on MMU? Or it can actually work even
> if CONFIG_MMU=n?

It should work when CONFIG_MMU=n, but I doubt anyone regularly attempts to 
do so (if ever).

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
