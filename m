Date: Thu, 1 May 2008 12:25:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080501014418.GB15179@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805011224150.8738@schroedinger.engr.sgi.com>
References: <20080422045205.GH21993@wotan.suse.de>
 <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
 <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
 <20080423004804.GA14134@wotan.suse.de> <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
 <20080430065611.GH27652@wotan.suse.de> <20080430001249.c07ff5c8.akpm@linux-foundation.org>
 <20080430072620.GI27652@wotan.suse.de> <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
 <20080501014418.GB15179@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 1 May 2008, Nick Piggin wrote:

> Yes if PageUptodate and the page is locked, then I don't believe
> any read IO should happen.

Ok so page migration should check for that and not migrate a page that is 
!Uptodate?

> But you definitely do seem to be migrating !PageUptodate pages. In
> that case I think it works because of buffer_migrate_page which takes
> the buffer locks and holds off read IO to buffers too.

Comes about because memory offlining gets to pages that are not mapped 
into a process address space.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
