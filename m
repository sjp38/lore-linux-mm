Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11580
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:37:17 -0500
Date: Sat, 19 Dec 1998 16:36:54 GMT
Message-Id: <199812191636.QAA01194@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219171852.506A-100000@laser.bogus>
References: <Pine.LNX.3.96.981219165802.208A-100000@laser.bogus>
	<Pine.LNX.3.96.981219171852.506A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 19 Dec 1998 17:23:13 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> I've put a new patch with as difference only a bit of credits added ;) at:
> ftp://e-mind.com/pub/linux/kernel-patches/pgclean-0-2.1.132-2.diff.gz

> All tests I done here are been succesfully (and I am using huge size of
> memory just to be sure to notice any kind of mm corruption). Does somebody
> has some test suite for shared mappings or could suggest me a proggy that
> uses heavly shared mappings?

ftp.uk.linux.org:/pub/linux/sct/vm/shm-stress.tar.gz

It currently uses only sysV shared maps, but it would be trivial to
extend it to use shared map files.  Let me know if you make the change
and I'll merge the patch in.

The test stuff uses separate shared-write regions for testing: one
smaller region is used as a bitmap, and the code keeps primitive
spinlocks in this bit to synchronise access to the rest of the shared
memory.  The rest of the shared memory is used as a test heap --- just a
collection of separate test pages --- and a pattern array.  We store
random patterns in the first word of each test page in the heap, and
(under spinlock) assign the same pattern atomically to both the test
page and the appropriate entry in the pattern array.  Use a sufficiently
large test heap and you can test shared-page swapping quite effectively.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
