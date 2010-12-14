Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 124FE6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 15:38:36 -0500 (EST)
Subject: Re: [PATCH 16/35] writeback: increase min pause time on concurrent dirtiers
In-Reply-To: Your message of "Tue, 14 Dec 2010 21:24:15 +0100."
             <1292358255.13513.390.camel@laptop>
From: Valdis.Kletnieks@vt.edu
References: <20101213144646.341970461@intel.com> <20101213150328.284979629@intel.com> <15881.1292264611@localhost> <20101214065133.GA6940@localhost> <14658.1292352152@localhost> <1292352908.13513.376.camel@laptop> <20252.1292357637@localhost>
            <1292358255.13513.390.camel@laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292359075_5019P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Dec 2010 15:37:55 -0500
Message-ID: <21373.1292359075@localhost>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1292359075_5019P
Content-Type: text/plain; charset=us-ascii

On Tue, 14 Dec 2010 21:24:15 +0100, Peter Zijlstra said:

> You're confused. 10*HZ jiffies is always 10 seconds.

I must be misremembering times past, when HZ was settable
but a jiffie was always 1/100th of a second...  Senility has
finally set it. :)

--==_Exmh_1292359075_5019P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNB9WjcC3lWbTT17ARAj7+AJ9/OF4KRUBMv0x5wXfUMLmmedtWvACffjh3
SVZe9YHIxLX+IUkfoJ5o9ds=
=MxJx
-----END PGP SIGNATURE-----

--==_Exmh_1292359075_5019P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
