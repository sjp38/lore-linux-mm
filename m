Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AAE906B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 13:39:55 -0500 (EST)
Subject: Re: [PATCH 16/35] writeback: increase min pause time on concurrent dirtiers
In-Reply-To: Your message of "Tue, 14 Dec 2010 19:55:08 +0100."
             <1292352908.13513.376.camel@laptop>
From: Valdis.Kletnieks@vt.edu
References: <20101213144646.341970461@intel.com> <20101213150328.284979629@intel.com> <15881.1292264611@localhost> <20101214065133.GA6940@localhost> <14658.1292352152@localhost>
            <1292352908.13513.376.camel@laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292357637_5019P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Dec 2010 15:13:57 -0500
Message-ID: <20252.1292357637@localhost>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1292357637_5019P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <20222.1292357614.1@localhost>

On Tue, 14 Dec 2010 19:55:08 +0100, Peter Zijlstra said:

> 10*HZ = 10 seconds
> (10*HZ) / 1024 ~= 10 milliseconds

from include/asm-generic/param.h (which is included by x86)

#ifdef __KERNEL__
# define HZ             CONFIG_HZ       /* Internal kernel timer frequency */
# define USER_HZ        100             /* some user interfaces are */
# define CLOCKS_PER_SEC (USER_HZ)       /* in "ticks" like times() */
#endif

Note that HZ isn't USER_HZ or CLOCKS_PER_SEC  - it's CONFIG_HZ, which last
I checked is still user-settable.  If not, then there needs to be a massive cleanup
of Kconfig and defconfig:

% grep HZ .config
CONFIG_NO_HZ=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000

So you're not guaranteed that 10*HZ is 10 seconds.  10*USER_HZ, sure. But not HZ.





--==_Exmh_1292357637_5019P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNB9AFcC3lWbTT17ARAiAEAKC0yjII9TJD8lfJXeSnMkXkUjX/VQCfQSRX
BtQWcpp8YUP/QPYYfDiFDLk=
=Aycg
-----END PGP SIGNATURE-----

--==_Exmh_1292357637_5019P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
