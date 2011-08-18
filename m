Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1EB06B00EE
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 14:28:01 -0400 (EDT)
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
In-Reply-To: Your message of "Thu, 18 Aug 2011 16:41:53 +0200."
             <20110818144153.GA19920@redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1313650253-21794-1-git-send-email-gthelen@google.com> <20110818093800.GA2268@redhat.com> <96939.1313677618@turing-police.cc.vt.edu>
            <20110818144153.GA19920@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1313692071_2611P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Aug 2011 14:27:51 -0400
Message-ID: <8365.1313692071@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--==_Exmh_1313692071_2611P
Content-Type: text/plain; charset=us-ascii

On Thu, 18 Aug 2011 16:41:53 +0200, Johannes Weiner said:
> On Thu, Aug 18, 2011 at 10:26:58AM -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Thu, 18 Aug 2011 11:38:00 +0200, Johannes Weiner said:
> > 
> > > Note that on non-x86, these operations themselves actually disable and
> > > reenable preemption each time, so you trade a pair of add and sub on
> > > x86
> > > 
> > > -	preempt_disable()
> > > 	__this_cpu_xxx()
> > > 	__this_cpu_yyy()
> > > -	preempt_enable()
> > > 
> > > with
> > > 
> > > 	preempt_disable()
> > > 	__this_cpu_xxx()
> > > +	preempt_enable()
> > > +	preempt_disable()
> > > 	__this_cpu_yyy()
> > > 	preempt_enable()
> > > 
> > > everywhere else.
> > 
> > That would be an unexpected race condition on non-x86, if you expected _xxx and
> > _yyy to be done together without a preempt between them. Would take mere
> > mortals forever to figure that one out. :)
> 
> That should be fine, we don't require the two counters to be perfectly
> coherent with respect to each other, which is the justification for
> this optimization in the first place.

I meant the general case - when reviewing code, I wouldn't expect 2 lines of code
wrapped in preempt disable/enable to have a preempt window in the middle. ;)

--==_Exmh_1313692071_2611P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOTVmncC3lWbTT17ARAsAVAKC1b5V9INlQmsHK6z1zZvAMTcqa4ACfTcSs
GPK+HdG6a1iJ24jq/1lhWGs=
=bIfE
-----END PGP SIGNATURE-----

--==_Exmh_1313692071_2611P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
