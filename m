Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA18039
	for <linux-mm@kvack.org>; Wed, 26 May 1999 15:22:27 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14156.18924.10333.781178@dukat.scot.redhat.com>
Date: Wed, 26 May 1999 20:22:20 +0100 (BST)
Subject: Re: kernel_lock() profiling results
In-Reply-To: <374C3237.2D89878@colorfullife.com>
References: <3748111C.3F040C1F@colorfullife.com>
	<14156.8862.155397.630098@dukat.scot.redhat.com>
	<374C3237.2D89878@colorfullife.com>
Sender: owner-linux-mm@kvack.org
To: masp0008@stud.uni-sb.de
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "David S. Miller" <davem@dm.cobaltmicro.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 26 May 1999 19:41:11 +0200, Manfred Spraul
<manfreds@colorfullife.com> said:

> 1) Andrea noticed that 'unlock_kernel()' only releases the kernel lock
> if the lock was obtained once.

Yes, but in all the places we are currently doing the copy_*_user, we
only hold the lock once.  In general we might want to do a true
save/restore of lock_depth for a new, self-unlocking copy_*_user, but
right now the droplock diffs still do the right thing the simple way.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
