Date: Thu, 8 Jun 2000 15:08:21 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: raid0 and buffers larger than PAGE_SIZE
Message-ID: <20000608150821.G3886@redhat.com>
References: <20000607204444.A453@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000607204444.A453@perlsupport.com>; from chip@valinux.com on Wed, Jun 07, 2000 at 08:44:44PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chip Salzenberg <chip@valinux.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 08:44:44PM -0700, Chip Salzenberg wrote:

> I'm using raid0 under 2.2.16pre4 and I've just started observing a new
> failure mode that's completely preventing it from working: getblk(),
> and therefore refill_freelist(), is being called with a size greater
> than PAGE_SIZE.  This is triggered by e2fsck on the /dev/md0, and it's
> probably been a while since the last e2fsck, so I don't know when the
> was actually introduced.

getblk() with blocksize > PAGE_SIZE is completely illegal.  Are you
using a decent set of raid patches?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
