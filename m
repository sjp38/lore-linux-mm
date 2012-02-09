Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 7EB906B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 08:04:27 -0500 (EST)
From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: Re: swap storm since kernel 3.2.x
Date: Thu, 9 Feb 2012 14:04:21 +0100
References: <201202041109.53003.toralf.foerster@gmx.de> <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com> <20120209113606.GA8054@sig21.net>
In-Reply-To: <20120209113606.GA8054@sig21.net>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201202091404.22470.toralf.foerster@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Stezenbach <js@sig21.net>
Cc: Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org


Johannes Stezenbach wrote at 12:36:06
> On Wed, Feb 08, 2012 at 08:34:14PM +0800, Hillf Danton wrote:
> > And I want to ask kswapd to do less work, the attached diff is
> > based on 3.2.5, mind to test it with CONFIG_DEBUG_OBJECTS enabled?
>=20
> Sorry, for slow reply.  The patch does not apply to 3.2.4
> (3.2.5 only has the ASPM change which I don't want to
> try atm).  Is the patch below correct?
>=20
confirmed - doesn't apply here too :-(

=2D-=20
MfG/Sincerely
Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
