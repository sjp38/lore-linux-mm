Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA18206
	for <linux-mm@kvack.org>; Fri, 28 May 1999 20:46:44 -0400
Date: Sat, 29 May 1999 02:45:20 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kernel_lock() profiling results
In-Reply-To: <14156.18924.10333.781178@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9905290241440.1597-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: masp0008@stud.uni-sb.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "David S. Miller" <davem@dm.cobaltmicro.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 1999, Stephen C. Tweedie wrote:

>save/restore of lock_depth for a new, self-unlocking copy_*_user, but
>right now the droplock diffs still do the right thing the simple way.

I wouldn't call it the "right thing". It's also not simpler according to
me since to make sure that the unlock_kernel is really dropping the
kernel_flag spinlock you must check all entry paths and verify that
lock_depth is 0 at such time.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
