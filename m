Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 72A5C900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 08:07:08 -0400 (EDT)
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 12 Sep 2011 14:06:43 +0200
In-Reply-To: <20110912115605.GB3207@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
	 <1315566054-17209-4-git-send-email-mgorman@suse.de>
	 <20110909130007.GA11810@infradead.org> <20110909131550.GV14369@suse.de>
	 <20110909133611.GB8155@infradead.org> <1315818285.26517.18.camel@twins>
	 <20110912093058.GA3207@suse.de> <1315821369.26517.21.camel@twins>
	 <20110912115605.GB3207@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315829203.26517.30.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>

On Mon, 2011-09-12 at 12:56 +0100, Mel Gorman wrote:

> I took a look at what was involved with doing the block lookups in
> ext4. It's what led to patch 4 of this series because it was necessary th=
at
> the filesystem get the same information as the generic handler. It got a
> bit messy but looked like it would have worked if I kept at it. I stopped
> because I did nt see a major advantage with swap_writepage() looking up
> the block map instead of having looked it up in advance with bmap() but
> I could have missed something.

IIRC the filesystem folks don't like the bmap thing and would like it to
go away.. could be they changed their minds again though, who knows ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
