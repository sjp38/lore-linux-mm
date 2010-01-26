Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EBC826B0096
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 16:29:07 -0500 (EST)
Date: Tue, 26 Jan 2010 15:29:04 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100126212904.GE6653@sgi.com>
References: <20100125174556.GA23003@sgi.com>
 <20100125190052.GF5756@random.random>
 <20100125211033.GA24272@sgi.com>
 <20100125211615.GH5756@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125211615.GH5756@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, cl@linux-foundation.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 10:16:15PM +0100, Andrea Arcangeli wrote:
> The old patches are in my ftp area, they should still apply, you
> should concentrate testing with those additional ones applied, then it
> will work for xpmem too ;)

Andrea, could you point me at your ftp area?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
