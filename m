Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA16274
	for <linux-mm@kvack.org>; Wed, 26 May 1999 12:34:55 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14156.8862.155397.630098@dukat.scot.redhat.com>
Date: Wed, 26 May 1999 17:34:38 +0100 (BST)
Subject: Re: kernel_lock() profiling results
In-Reply-To: <3748111C.3F040C1F@colorfullife.com>
References: <3748111C.3F040C1F@colorfullife.com>
Sender: owner-linux-mm@kvack.org
To: masp0008@stud.uni-sb.de
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "David S. Miller" <davem@dm.cobaltmicro.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 23 May 1999 16:30:52 +0200, Manfred Spraul
<manfreds@colorfullife.com> said:

> Shouldn't we change file_read_actor() [mm/filemap.c, the function which
> copies data from the page cache to user mode]:
> we could release the kernel lock if we copy more than 1024 bytes.
> (we currently do that only if the user mode memory is not paged in.)

	ftp://ftp.uk.linux.org/pub/linux/sct/performance

contains a patch Dave Miller and I put together to drop the kernel lock
during a number of key user mode copies.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
