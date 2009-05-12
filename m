Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7D106B00A3
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:27:19 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DD27282CC36
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:40:18 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xhRptI8mo2OJ for <linux-mm@kvack.org>;
	Tue, 12 May 2009 16:40:18 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E0EF982CC70
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:40:11 -0400 (EDT)
Date: Tue, 12 May 2009 16:26:50 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
In-Reply-To: <4A09D957.2070908@redhat.com>
Message-ID: <alpine.DEB.1.10.0905121623560.16057@qirst.com>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <4A09AC91.4060506@redhat.com> <alpine.DEB.1.10.0905121718040.24066@qirst.com>
 <4A09B46D.9010705@redhat.com> <alpine.DEB.1.10.0905121801080.19973@qirst.com> <4A09D957.2070908@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009, Rik van Riel wrote:

> How many do you want before you're satisfied that this
> benefits a significant number of workloads?

One would be a good starter.

> How many numbers do you want to feel safe that no workloads
> suffer badly from this patch?
>
> Also, wow would you measure a concept as nebulous as desktop
> interactivity?

Measure the response to desktop clicks? I.e. retrieve an URL with a
webbrowser that was running when the other load started.

> Btw, the patch has gone into the Fedora kernel RPM to get
> a good amount of user testing.  I'll let you know what the
> users say (if anything).

I have not seen a single reference to a measurement taken with this patch.

Maybe that is because I have not looked at the threads that discuss
measurements with this patch. Where are they?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
