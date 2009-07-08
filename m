Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2358B6B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 21:39:46 -0400 (EDT)
Date: Wed, 8 Jul 2009 09:44:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
Message-ID: <20090708014425.GA6464@localhost>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182451.08FF.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071238570.5124@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907071238570.5124@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 12:46:54AM +0800, Christoph Lameter wrote:
> On Sun, 5 Jul 2009, KOSAKI Motohiro wrote:
> 
> >  mm/vmstat.c            |    2 +-
> >  6 files changed, 14 insertions(+), 3 deletions(-)
> >
> > Index: b/fs/proc/meminfo.c
> > ===================================================================
> > --- a/fs/proc/meminfo.c
> > +++ b/fs/proc/meminfo.c
> > @@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
> >  		"Active(file):   %8lu kB\n"
> >  		"Inactive(file): %8lu kB\n"
> >  		"Unevictable:    %8lu kB\n"
> > +		"IsolatedPages:  %8lu kB\n"
> 
> Why is it called isolatedpages when we display the amount of memory in
> kilobytes?

See following emails. This has been changed to "IsolatedLRU" and then
"Isolated(file)/Isolated(anon)".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
