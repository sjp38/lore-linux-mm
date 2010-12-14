Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC49B6B0089
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 13:43:23 -0500 (EST)
Subject: Re: [PATCH 16/35] writeback: increase min pause time on concurrent dirtiers
In-Reply-To: Your message of "Tue, 14 Dec 2010 14:51:33 +0800."
             <20101214065133.GA6940@localhost>
From: Valdis.Kletnieks@vt.edu
References: <20101213144646.341970461@intel.com> <20101213150328.284979629@intel.com> <15881.1292264611@localhost>
            <20101214065133.GA6940@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292352152_5019P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Dec 2010 13:42:32 -0500
Message-ID: <14658.1292352152@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1292352152_5019P
Content-Type: text/plain; charset=us-ascii

On Tue, 14 Dec 2010 14:51:33 +0800, Wu Fengguang said:

> > > +	/* (N * 10ms) on 2^N concurrent tasks */
> > > +	t = (hi - lo) * (10 * HZ) / 1024;
> > 
> > Either I need more caffeine, or the comment doesn't match the code
> > if HZ != 1000?
> 
> The "ms" in the comment may be confusing, but the pause time (t) is
> measured in jiffies :)  Hope the below patch helps.

No, I meant that 10 * HZ evaluates to different numbers depending what
the CONFIG_HZ parameter is set to - 100, 250, 1000, or some other
custom value.  Does this code behave correctly on a CONFIG_HZ=100 kernel?


--==_Exmh_1292352152_5019P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNB7qYcC3lWbTT17ARAvTMAKC/ht0Fks0Or0Vt5OCz0fm3BUJrpQCeM8zE
81BeEo8scun4qECHwhkfUDE=
=q+q1
-----END PGP SIGNATURE-----

--==_Exmh_1292352152_5019P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
