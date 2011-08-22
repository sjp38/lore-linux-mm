Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 804996B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 17:50:54 -0400 (EDT)
Date: Mon, 22 Aug 2011 14:50:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
Message-Id: <20110822145050.e3471fa0.akpm@linux-foundation.org>
In-Reply-To: <20110822135218.f2d9f462.akpm@linux-foundation.org>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
	<1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
	<20110822135218.f2d9f462.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-arch@vger.kernel.org

On Mon, 22 Aug 2011 13:52:18 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	value64 = value | value << 8 | value << 16 | value << 24;
> > +	value64 = (value64 & 0xffffffff) | value64 << 32;
> > +	prefix = 8 - ((unsigned long)start) % 8;
> > +
> > +	if (prefix) {
> > +		u8 *r = check_bytes8(start, value, prefix);
> > +		if (r)
> > +			return r;
> > +		start += prefix;
> > +		bytes -= prefix;
> > +	}
> > +
> > +	words = bytes / 8;
> > +
> > +	while (words) {
> > +		if (*(u64 *)start != value64)
> 
> OK, problem.  This will explode if passed a misaligned address on
> certain (non-x86) architectures.

pls ignore.  As Marcin points out, I can't read.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
