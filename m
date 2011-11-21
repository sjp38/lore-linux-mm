Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDA26B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:06:40 -0500 (EST)
Date: Mon, 21 Nov 2011 05:06:22 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Message-ID: <20111121100622.GA17887@infradead.org>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com>
 <20111119100326.GA27967@infradead.org>
 <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Sat, Nov 19, 2011 at 03:14:48PM +0100, Kay Sievers wrote:
> On Sat, Nov 19, 2011 at 11:03, Christoph Hellwig <hch@infradead.org> wrote:
> > On Fri, Nov 18, 2011 at 06:39:50PM +0800, Cong Wang wrote:
> >> It seems that systemd needs tmpfs to support fallocate,
> >> see http://lkml.org/lkml/2011/10/20/275. This patch adds
> >> fallocate support to tmpfs.
> >
> > What for exactly? ??Please explain why preallocating on tmpfs would
> > make any sense.
> 
> To be able to safely use mmap(), regarding SIGBUS, on files on the
> /dev/shm filesystem. The glibc fallback loop for -ENOSYS on fallocate
> is just ugly.

That is the kind of information which needs to be in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
