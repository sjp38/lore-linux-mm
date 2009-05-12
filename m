Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EE2B6B00A0
	for <linux-mm@kvack.org>; Tue, 12 May 2009 14:03:41 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3E3D782CE0F
	for <linux-mm@kvack.org>; Tue, 12 May 2009 14:16:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AXdpPbGqxcZw for <linux-mm@kvack.org>;
	Tue, 12 May 2009 14:16:17 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7CAF382CDEA
	for <linux-mm@kvack.org>; Tue, 12 May 2009 14:16:12 -0400 (EDT)
Date: Tue, 12 May 2009 18:02:21 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
In-Reply-To: <4A09B46D.9010705@redhat.com>
Message-ID: <alpine.DEB.1.10.0905121801080.19973@qirst.com>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <4A09AC91.4060506@redhat.com> <alpine.DEB.1.10.0905121718040.24066@qirst.com>
 <4A09B46D.9010705@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009, Rik van Riel wrote:

> > Streaming I/O means access once?
>
> Yeah, "used-once pages" would be a better criteria, since
> you could go through a gigantic set of used-once pages without
> doing linear IO.

Can we see some load for which this patch has a beneficial effect?
With some numbers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
