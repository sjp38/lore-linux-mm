Date: Thu, 1 May 2008 18:07:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080502004445.GB30768@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805011805150.13527@schroedinger.engr.sgi.com>
References: <20080422094352.GB23770@wotan.suse.de>
 <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
 <20080423004804.GA14134@wotan.suse.de> <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
 <20080430065611.GH27652@wotan.suse.de> <20080430001249.c07ff5c8.akpm@linux-foundation.org>
 <20080430072620.GI27652@wotan.suse.de> <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
 <20080501014418.GB15179@wotan.suse.de> <Pine.LNX.4.64.0805011224150.8738@schroedinger.engr.sgi.com>
 <20080502004445.GB30768@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 May 2008, Nick Piggin wrote:

> On Thu, May 01, 2008 at 12:25:54PM -0700, Christoph Lameter wrote:
> > On Thu, 1 May 2008, Nick Piggin wrote:
> > 
> > > Yes if PageUptodate and the page is locked, then I don't believe
> > > any read IO should happen.
> > 
> > Ok so page migration should check for that and not migrate a page that is 
> > !Uptodate?
> 
> Buffer migration seems to work OK now, why do you need to add the
> restriction?

Because we have to protect against read I/O. We cannot migrate 
a page that is under I/O and free the memory that is being written to by a 
device.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
