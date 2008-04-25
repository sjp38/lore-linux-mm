Date: Fri, 25 Apr 2008 09:11:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080425091135.40336844.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0804241208470.27853@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080422045205.GH21993@wotan.suse.de>
	<20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080422094352.GB23770@wotan.suse.de>
	<Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
	<20080423004804.GA14134@wotan.suse.de>
	<20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080423025358.GA9751@wotan.suse.de>
	<20080423124425.5c80d3cf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804231048120.12373@schroedinger.engr.sgi.com>
	<20080424103659.90a1006d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804241208470.27853@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Apr 2008 12:11:07 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 24 Apr 2008, KAMEZAWA Hiroyuki wrote:
> 
> > > So its safe to migrate a !Uptodate page if it contains buffers? Note that 
> > > the migration code reattaches the buffer to the new page in 
> > > buffer_migrate_page().
> > > 
> > I think it's safe because it reattaches buffers as you explained.
> > 
> > under migration
> > 1. a page is locked.
> > 2. buffers are reattached.
> > 3. a PG_writeback page are not migrated.
> > 
> > So, it seems safe.
> 
> Concurrent DMA reads cannot occur while we migrate? What holds off 
> potential I/O to the page? The page lock? Or some buffer lock?
> 
> Not that the "buffers" are segments of the page that is migrated.
> If concurrent transfers occur while we copy the page then we may see data 
> corruption.
> 
Hmm ? If a buffer in a page is under I/O, the whole page is locked, isn't it ?
If not, It seems anyone cannot use a page safely.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
