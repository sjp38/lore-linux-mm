Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C24136B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:35:35 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rp2so1202110pbb.15
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:35:35 -0800 (PST)
Date: Sun, 27 Jan 2013 19:35:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
In-Reply-To: <1359333371.6763.12.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271932070.896@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251759470.29196@eggly.anvils> <1359254187.4159.10.camel@kernel> <alpine.LNX.2.00.1301271355430.17144@eggly.anvils> <1359333371.6763.12.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Jan 2013, Simon Jeons wrote:
> On Sun, 2013-01-27 at 14:08 -0800, Hugh Dickins wrote:
> > On Sat, 26 Jan 2013, Simon Jeons wrote:
> > > 
> > > Why the parameter lock passed from stable_tree_search/insert is true,
> > > but remove_rmap_item_from_tree is false?
> > 
> > The other way round?  remove_rmap_item_from_tree needs the page locked,
> > because it's about to modify the list: that's secured (e.g. against
> > concurrent KSM page reclaim) by the page lock.
> 
> How can KSM page reclaim path call remove_rmap_item_from_tree? I have
> already track every callsites but can't find it.

It doesn't.  Please read what I said above again.

> BTW, I'm curious about
> KSM page reclaim, it seems that there're no special handle in vmscan.c
> for KSM page reclaim, is it will be reclaimed similiar with normal
> page? 

Look for PageKsm in mm/rmap.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
