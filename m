Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 190806B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:35:15 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o1FMZQeD014048
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:35:26 GMT
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by spaceape23.eur.corp.google.com with ESMTP id o1FMZOAY020930
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:35:25 -0800
Received: by pwi9 with SMTP id 9so643299pwi.24
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:35:24 -0800 (PST)
Date: Mon, 15 Feb 2010 14:35:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 6/9 v2] oom: deprecate oom_adj tunable
In-Reply-To: <20100215222845.0b0f2781@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1002151433040.1324@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418560.26927@chino.kir.corp.google.com> <20100215222845.0b0f2781@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, Alan Cox wrote:

> > /proc/pid/oom_adj is now deprecated so that that it may eventually be
> > removed.  The target date for removal is December 2011.
> 
> There are systems that rely on this feature. It's ABI, its sacred. We are
> committed to it and it has users. That doesn't really detract from the
> good/bad of the rest of the proposal, it's just one step we can't quite
> make.
> 

Andrew suggested that it be deprecated in this way, so that's what was 
done.  I don't have any strong opinions about leaving it around forever 
now that it's otherwise unused beyond simply converting itself into units 
for /proc/pid/oom_score_adj at a much higher granularity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
