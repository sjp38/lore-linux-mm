Date: Thu, 24 Apr 2008 10:34:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080424103407.ea36cca0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080423152809.GA16769@wotan.suse.de>
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
	<20080423152809.GA16769@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Apr 2008 17:28:09 +0200
Nick Piggin <npiggin@suse.de> wrote:
> > Is this correct ?
> > ==
> > set_page_dirty_buffers() (in fs/buffer.c) makes a page and _all_ buffers on it
> > dirty. So, a page *must* be up-to-date when it calls set_page_dirty_buffers().
> > This is used for mapped pages or some callers which requires the whole
> > page containes valid data.
> > 
> > In set_page_dirty_nobuffers()case , it just makes a page to be dirty. We can't
> > see whether a page is really up-to-date or not when PagePrivate(page) &&
> > !PageUptodate(page). This is used for a page which contains some data
> > to be written out. (part of buffers contains data.)
> > 
> > ==
> 
> Yes I think you have it correct. 
> 

Thank you for kindly explanation.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
