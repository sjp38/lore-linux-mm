Date: Thu, 17 Apr 2008 15:55:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (possible in migration ?)
Message-Id: <20080417155557.a08cbde5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080416234303.c6003c08.akpm@linux-foundation.org>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080416200036.2ea9b5c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20080416113642.8ffd5684.akpm@linux-foundation.org>
	<20080417091930.cbac6286.kamezawa.hiroyu@jp.fujitsu.com>
	<20080417153818.d40ddfd8.kamezawa.hiroyu@jp.fujitsu.com>
	<20080416234303.c6003c08.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, npiggin@suse.de, y-goto@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008 23:43:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 17 Apr 2008 15:38:18 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 17 Apr 2008 09:19:30 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > I'd expect that you could reproduce this by disabling readahead with
> > > > fadvise(POSIX_FADV_RANDOM) and then issuing the above four reads.
> > > > 
> > > Thank you for advice. I'll try.
> > > 
> > (Added lkml to CC:)
> > 
> > What happens:
> >   When I do memory offline on ia64/NUMA box, __set_page_dirty_buffers() printed
> >   out WARNINGS because the page under migration is not up-to-date.
> 
> The warning is in __set_page_dirty().
> 
Sorry, __set_page_dirty() in fs/buffer.c 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
