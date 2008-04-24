Date: Thu, 24 Apr 2008 12:11:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080424103659.90a1006d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0804241208470.27853@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
 <20080422045205.GH21993@wotan.suse.de> <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
 <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
 <20080423004804.GA14134@wotan.suse.de> <20080423114107.b8df779c.kamezawa.hiroyu@jp.fujitsu.com>
 <20080423025358.GA9751@wotan.suse.de> <20080423124425.5c80d3cf.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804231048120.12373@schroedinger.engr.sgi.com>
 <20080424103659.90a1006d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Apr 2008, KAMEZAWA Hiroyuki wrote:

> > So its safe to migrate a !Uptodate page if it contains buffers? Note that 
> > the migration code reattaches the buffer to the new page in 
> > buffer_migrate_page().
> > 
> I think it's safe because it reattaches buffers as you explained.
> 
> under migration
> 1. a page is locked.
> 2. buffers are reattached.
> 3. a PG_writeback page are not migrated.
> 
> So, it seems safe.

Concurrent DMA reads cannot occur while we migrate? What holds off 
potential I/O to the page? The page lock? Or some buffer lock?

Not that the "buffers" are segments of the page that is migrated.
If concurrent transfers occur while we copy the page then we may see data 
corruption.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
