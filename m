Date: Tue, 6 May 2008 10:49:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080506085234.GB10141@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805061048260.23336@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
 <20080501014418.GB15179@wotan.suse.de> <Pine.LNX.4.64.0805011224150.8738@schroedinger.engr.sgi.com>
 <20080502004445.GB30768@wotan.suse.de> <Pine.LNX.4.64.0805011805150.13527@schroedinger.engr.sgi.com>
 <20080502012350.GF30768@wotan.suse.de> <Pine.LNX.4.64.0805011833480.13697@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0805021411260.21677@schroedinger.engr.sgi.com>
 <20080505042751.GB26920@wotan.suse.de> <Pine.LNX.4.64.0805051026040.8885@schroedinger.engr.sgi.com>
 <20080506085234.GB10141@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008, Nick Piggin wrote:

> > Is there any easy way to check if any of the buffers are locked? It would 
> > be good if we could skip the pages with pending I/O on the first migration 
> > passes and only get to them after most of the others have been migrated. 
> > The taking of the buffer locks instead of the page lock defeats the scheme 
> > to defer the difficult migrations till later.
> 
> Can't you just test whether the buffers are locked?

That would mean adding some ugly code that check before we lock the page 
if we will be using buffer_migrate_page() later and then loop over the 
buffers checking for lock bits? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
