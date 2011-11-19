Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1F76B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 05:03:42 -0500 (EST)
Date: Sat, 19 Nov 2011 05:03:26 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Message-ID: <20111119100326.GA27967@infradead.org>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321612791-4764-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, Nov 18, 2011 at 06:39:50PM +0800, Cong Wang wrote:
> It seems that systemd needs tmpfs to support fallocate,
> see http://lkml.org/lkml/2011/10/20/275. This patch adds
> fallocate support to tmpfs.

What for exactly?  Please explain why preallocating on tmpfs would
make any sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
