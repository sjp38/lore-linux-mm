Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 14E636B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 17:55:39 -0400 (EDT)
Date: Sat, 18 Jun 2011 14:55:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
Message-Id: <20110618145546.12e175bf.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1106140342330.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140342330.29206@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 14 Jun 2011 03:43:47 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> In an i386 kernel this limits its information (type and page offset)
> to 30 bits: given 32 "types" of swapfile and 4kB pagesize, that's
> a maximum swapfile size of 128GB.  Which is less than the 512GB we
> previously allowed with X86_PAE (where the swap entry can occupy the
> entire upper 32 bits of a pte_t), but not a new limitation on 32-bit
> without PAE; and there's not a new limitation on 64-bit (where swap
> filesize is already limited to 16TB by a 32-bit page offset).

hm.

>  Thirty
> areas of 128GB is probably still enough swap for a 64GB 32-bit machine.

What if it was only one area?  128GB is close enough to 64GB (or, more
realistically, 32GB) to be significant.  For the people out there who
are using a single 200GB swap partition and actually needed that much,
what happens?  swapon fails?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
