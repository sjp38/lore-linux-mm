Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 834B06B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:51:36 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6BD8E82C5E8
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:11:41 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n3zuZYZF6unU for <linux-mm@kvack.org>;
	Tue,  7 Jul 2009 13:11:41 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A146E82C5FD
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:11:36 -0400 (EDT)
Date: Tue, 7 Jul 2009 12:53:17 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <28c262360907050827y577c3859g5e05e82935e96010@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0907071252060.5124@gentwo.org>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com>  <20090705121308.GC5252@localhost>  <20090705211739.091D.A69D9226@jp.fujitsu.com>  <20090705130200.GA6585@localhost>  <2f11576a0907050619t5dea33cfwc46344600c2b17b5@mail.gmail.com>
 <28c262360907050804p70bc293uc7330a6d968c0486@mail.gmail.com>  <20090705151628.GA11307@localhost> <28c262360907050827y577c3859g5e05e82935e96010@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Jul 2009, Minchan Kim wrote:

> Anyway, I think it's not a big cost in normal system.
> So If you want to add new accounting, I don't have any objection. :)

Lets keep the counters to a mininum. If we can calculate the values from
something else then there is no justification for a new counter.

A new counter increases the size of the per cpu structures that exist for
each zone and each cpu. 1 byte gets multiplies by the number of cpus and
that gets multiplied by the number of zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
