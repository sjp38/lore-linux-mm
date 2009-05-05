Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 106DC6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 11:54:00 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9750782C240
	for <linux-mm@kvack.org>; Tue,  5 May 2009 12:06:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Xe+y3gpFLY7R for <linux-mm@kvack.org>;
	Tue,  5 May 2009 12:06:38 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C3BED82C248
	for <linux-mm@kvack.org>; Tue,  5 May 2009 12:06:31 -0400 (EDT)
Date: Tue, 5 May 2009 11:43:58 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] vmscan: don't export nr_saved_scan in
 /proc/zoneinfo
In-Reply-To: <1241509090.11059.31.camel@twins>
Message-ID: <alpine.DEB.1.10.0905051142580.11830@qirst.com>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org>  <20090501012212.GA5848@localhost>  <20090430194907.82b31565.akpm@linux-foundation.org>  <20090502023125.GA29674@localhost> <20090502024719.GA29730@localhost>  <20090504144915.8d0716d7.akpm@linux-foundation.org>
 <1241509090.11059.31.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, torvalds@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, lee.schermerhorn@hp.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 5 May 2009, Peter Zijlstra wrote:

> > /proc/zoneinfo is unsalvageable :( Shifting future work over to
> > /sys/devices/system/node/nodeN/meminfo and deprecating /proc/zoneinfo
> > sounds good to me.
>
> If only one could find things put in sysfs :-)

Write a "zoneinfo" command line tool to show this information? If we
cannot output large texts via /proc or /sys then we need small tools for
all sorts of statistics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
