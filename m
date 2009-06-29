Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C2B66B005A
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 11:53:49 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090629151417.GA29796@localhost>
References: <20090629151417.GA29796@localhost> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com> <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost> <29432.1246285300@redhat.com> <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com> 
Subject: Re: Found the commit that causes the OOMs
Date: Mon, 29 Jun 2009 16:54:45 +0100
Message-ID: <30071.1246290885@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>, dwmw2@infradead.org
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> Yes this time the OOM order/flags are much different from all previous OOMs.
> 
> btw, I found that msgctl11 is pretty good at making a lot of SUnreclaim and
> PageTables pages:

I got David Woodhouse to run this on one of this boxes, but he doesn't see the
problem, I think because he's got 4GB of RAM, and never comes close to running
out.

I've asked him to reboot with mem=1G to see if that helps reproduce it.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
