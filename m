Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E7F088D000C
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 17:39:32 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p07MdUjL015662
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 14:39:30 -0800
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz17.hot.corp.google.com with ESMTP id p07MdODT025091
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 14:39:28 -0800
Received: by pwj6 with SMTP id 6so3176854pwj.12
        for <linux-mm@kvack.org>; Fri, 07 Jan 2011 14:39:24 -0800 (PST)
Date: Fri, 7 Jan 2011 14:39:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 0/2] Tunable watermark
In-Reply-To: <AANLkTikQPXWkEJwN5fV2vnUS37Fs+GNzFXuFkKXcnzmu@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1101071436220.23858@chino.kir.corp.google.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com> <AANLkTikQPXWkEJwN5fV2vnUS37Fs+GNzFXuFkKXcnzmu@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, dle-develop@lists.sourceforge.net, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jan 2011, Ying Han wrote:

> On the other hand, having the low/high wmark consider more characters
> other than the
> size of the zone sounds useful.

The semantics of any watermark is to trigger events to happen at a 
specific level, so they should be static with respect to a frame of 
reference (which in the VM case is the min watermark with respect to the 
size of the zone).  If you're going to adjust the min watermark, it's then 
_mandatory_ to adjust the others to that frame of reference, you shouldn't 
need to tune them independently.

The problem that Satoru is reporting probably has nothing to do with the 
watermarks themselves but probably requires more aggressive action by 
kswapd and/or memory compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
