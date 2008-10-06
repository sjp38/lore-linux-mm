Date: Mon, 6 Oct 2008 11:09:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] Report the pagesize backing a VMA in /proc/pid/maps
Message-ID: <20081006100955.GB10212@csn.ul.ie>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-3-git-send-email-mel@csn.ul.ie> <20081004221339.GA20175@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081004221339.GA20175@x200.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (05/10/08 02:13), Alexey Dobriyan didst pronounce:
> On Fri, Oct 03, 2008 at 05:46:55PM +0100, Mel Gorman wrote:
> > This patch adds a new field for hugepage-backed memory regions to show the
> > pagesize in /proc/pid/maps.  While the information is available in smaps,
> > maps is more human-readable and does not incur the cost of calculating Pss. An
> > example of a /proc/self/maps output for an application using hugepages with
> > this patch applied is;
> > 
> > 08048000-0804c000 r-xp 00000000 03:01 49135      /bin/cat
> > 0804c000-0804d000 rw-p 00003000 03:01 49135      /bin/cat
> > 08400000-08800000 rw-p 00000000 00:10 4055       /mnt/libhugetlbfs.tmp.QzPPTJ (deleted) (hpagesize=4096kB)
> 
> > To be predictable for parsers, the patch adds the notion of reporting on VMA
> > attributes by appending one or more fields that look like "(attribute)". This
> > already happens when a file is deleted and the user sees (deleted) after the
> > filename. The expectation is that existing parsers will not break as those
> > that read the filename should be reading forward after the inode number
> > and stopping when it sees something that is not part of the filename.
> > Parsers that assume everything after / is a filename will get confused by
> > (hpagesize=XkB) but are already broken due to (deleted).
> 
> Looks like procps will start showing hpagesize tag as a mapping name
> (apologies for pasting crappy code):
> 

Looks that way. How about....
