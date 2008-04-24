Date: Thu, 24 Apr 2008 10:36:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080424103659.90a1006d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0804231048120.12373@schroedinger.engr.sgi.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008 10:50:33 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 23 Apr 2008, KAMEZAWA Hiroyuki wrote:
> 
> > In set_page_dirty_nobuffers()case , it just makes a page to be dirty. We can't
> > see whether a page is really up-to-date or not when PagePrivate(page) &&
> > !PageUptodate(page). This is used for a page which contains some data
> > to be written out. (part of buffers contains data.)
> 
> So its safe to migrate a !Uptodate page if it contains buffers? Note that 
> the migration code reattaches the buffer to the new page in 
> buffer_migrate_page().
> 
I think it's safe because it reattaches buffers as you explained.

under migration
1. a page is locked.
2. buffers are reattached.
3. a PG_writeback page are not migrated.

So, it seems safe.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
