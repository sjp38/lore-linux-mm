Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DECC36B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 14:39:18 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090627115306.GA1741@cmpxchg.org>
References: <20090627115306.GA1741@cmpxchg.org> <7561.1245768237@redhat.com> <20090624023251.GA16483@localhost> <20090624114055.225D.A69D9226@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
Date: Sat, 27 Jun 2009 19:40:17 +0100
Message-ID: <28520.1246128017@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> No, it has 600MB free pages after an OOM - which only means that the
> OOM killer did a good job ;-)

The system usually gets into a pretty much dead state after a couple of OOMs
of so.   There's also the little fact that prior to that commit, the OOMs
don't happen at all as far as I can tell.

I don't know for certain that the OOMs don't happen on the commits that have
come up good.  Sadly, all I can say is that after running N commits, I haven't
seen an OOM.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
