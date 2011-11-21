Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 935AC6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 17:13:35 -0500 (EST)
Received: by iaek3 with SMTP id k3so10475659iae.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 14:13:33 -0800 (PST)
Date: Mon, 21 Nov 2011 14:13:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
In-Reply-To: <20111121101059.GB17887@infradead.org>
Message-ID: <alpine.LSU.2.00.1111211405121.1879@sister.anvils>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com> <20111119100326.GA27967@infradead.org> <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com> <alpine.LSU.2.00.1111201322310.1264@sister.anvils>
 <20111121101059.GB17887@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Josef Bacik <josef@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 21 Nov 2011, Christoph Hellwig wrote:
> On Sun, Nov 20, 2011 at 01:39:12PM -0800, Hugh Dickins wrote:
> 
> > But since the present situation is that tmpfs has one interface to
> > punching holes, madvise(MADV_REMOVE), that IBM were pushing 5 years ago;
> > but ext4 (and others) now a fallocate(FALLOC_FL_PUNCH_HOLE) interface
> > which IBM have been pushing this year: we do want to normalize that
> > situation and make them all behave the same way.
> 
> FALLOC_FL_PUNCH_HOLE was added by Josef Bacik, who happens to work for
> Red Hat, but I doubt he was pushing any corporate agenda there, he was
> mostly making btrfs catch up with the 15 year old XFS hole punching
> ioctl.

Yeah, my apologies to Josef and to IBM and to XFS
for my regrettable little outburst of snarkiness :(

> 
> 
> > And if tmpfs is going to support fallocate(FALLOC_FL_PUNCH_HOLE),
> > looking at Amerigo's much more attractive V2 patch, it would seem
> > to me perverse to permit the deallocation but fail the allocation.
> 
> Agreed.

Thanks a lot for useful info, and saving me looking up the ENOSPC issue.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
