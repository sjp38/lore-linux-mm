From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.25285.780802.755159@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 23:20:53 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910111739210.18777-100000@weyl.math.psu.edu>
References: <14338.17669.163923.174022@dukat.scot.redhat.com>
	<Pine.GSO.4.10.9910111739210.18777-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 17:40:52 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

> Agreed, but the big lock does not (and IMHO should not) cover the vma list
> modifications.

Fine, but as I've said you need _something_.  It doesn't matter what,
but the fact that the kernel lock is no longer being held for vma
updates has introduced swapper races.  We can't fix those without either
restoring or replacing the big lock.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
