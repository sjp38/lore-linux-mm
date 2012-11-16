Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3E0926B0074
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:51:31 -0500 (EST)
Date: Fri, 16 Nov 2012 11:51:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
Message-Id: <20121116115124.c2981abc.akpm@linux-foundation.org>
In-Reply-To: <CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com>
References: <20121012135726.GY29125@suse.de>
	<507BDD45.1070705@suse.cz>
	<20121015110937.GE29125@suse.de>
	<5093A3F4.8090108@redhat.com>
	<5093A631.5020209@suse.cz>
	<509422C3.1000803@suse.cz>
	<509C84ED.8090605@linux.vnet.ibm.com>
	<509CB9D1.6060704@redhat.com>
	<20121109090635.GG8218@suse.de>
	<509F6C2A.9060502@redhat.com>
	<20121112113731.GS8218@suse.de>
	<CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

On Fri, 16 Nov 2012 14:14:47 -0500
Josh Boyer <jwboyer@gmail.com> wrote:

> > The temptation is to supply a patch that checks if kswapd was woken for
> > THP and if so ignore pgdat->kswapd_max_order but it'll be a hack and not
> > backed up by proper testing. As 3.7 is very close to release and this is
> > not a bug we should release with, a safer path is to revert "mm: remove
> > __GFP_NO_KSWAPD" for now and revisit it with the view to ironing out the
> > balance_pgdat() logic in general.
> >
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Does anyone know if this is queued to go into 3.7 somewhere?  I looked
> a bit and can't find it in a tree.  We have a few reports of Fedora
> rawhide users hitting this.

Still thinking about it.  We're reverting quite a lot of material
lately. 
mm-revert-mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures.patch
and revert-mm-fix-up-zone-present-pages.patch are queued for 3.7.

I'll toss this one in there as well, but I can't say I'm feeling
terribly confident.  How is Valdis's machine nowadays?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
