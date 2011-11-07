Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 249516B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 08:57:50 -0500 (EST)
Date: Mon, 7 Nov 2011 13:58:23 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
In-Reply-To: <1320675607.2330.0.camel@offworld>
References: <1320614101.3226.5.camel@offbook>
	<20111107112952.GB25130@tango.0pointer.de>
	<1320675607.2330.0.camel@offworld>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@gnu.org>
Cc: Lennart Poettering <mzxreary@0pointer.de>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>

> Right, rlimit approach guarantees a simple way of dealing with users
> across all tmpfs instances.

Which is almost certainly not what you want to happen. Think about direct
rendering.

For simple stuff tmpfs already supports size/nr_blocks/nr_inodes mount
options so you can mount private resource constrained tmpfs objects
already without kernel changes. No rlimit hacks needed - and rlimit is
the wrong API anyway.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
