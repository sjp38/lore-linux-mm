Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1265C6B004A
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:39:06 -0500 (EST)
Date: Tue, 16 Nov 2010 15:38:54 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4 Fix setting random pages PageUptodate
Message-ID: <20101116203854.GA1568@thunk.org>
References: <20101110152519.GA1626@arch.trippelsdorf.de>
 <20101110154057.GA2191@arch.trippelsdorf.de>
 <alpine.DEB.2.00.1011101534370.30164@router.home>
 <20101112122003.GA1572@arch.trippelsdorf.de>
 <20101115123846.GA30047@arch.trippelsdorf.de>
 <20101115195439.GA1569@arch.trippelsdorf.de>
 <AANLkTikWaADzUrqKhZ9gviW8sk8mPjC9kKFJyitvzQmx@mail.gmail.com>
 <20101116111339.GA1544@arch.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101116111339.GA1544@arch.trippelsdorf.de>
Sender: owner-linux-mm@kvack.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 12:13:39PM +0100, Markus Trippelsdorf wrote:
> ext4_end_bio calls put_page and kmem_cache_free before calling
> SetPageUpdate(). This can result in setting the PageUptodate bit on
> random pages and causes the following BUG:

Oops.   Thanks muchly to you and to Hugh for discovering this.

I've added this to the ext4 patch queue and will be pushing to Linus
this week, for -rc3.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
