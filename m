Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 999746B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 15:02:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <e51b28f7-da4a-4c53-889d-4f12b8dd701a@default>
Date: Tue, 1 Nov 2011 11:35:28 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
 <4E72284B.2040907@linux.vnet.ibm.com> <4E738B81.2070005@vflare.org
 1320168615.15403.80.camel@nimitz>
In-Reply-To: <1320168615.15403.80.camel@nimitz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Sent: Tuesday, November 01, 2011 11:30 AM
> To: Nitin Gupta
> Cc: Seth Jennings; Greg KH; gregkh@suse.de; devel@driverdev.osuosl.org; D=
an Magenheimer;
> cascardo@holoscopio.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org=
; brking@linux.vnet.ibm.com;
> rcj@linux.vnet.ibm.com
> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>=20
> On Fri, 2011-09-16 at 13:46 -0400, Nitin Gupta wrote:
> > I think replacing allocator every few weeks isn't a good idea. So, I
> > guess better would be to let me work for about 2 weeks and try the slab
> > based approach.  If nothing works out in this time, then maybe xcfmallo=
c
> > can be integrated after further testing.
>=20
> Hi Nitin,
>=20
> It's been about six weeks. :)
>=20
> Can we talk about putting xcfmalloc() in staging now?

FWIW, given that I am quoting "code rules!" to the gods of Linux
on another lkml thread, I can hardly disagree here.

If Nitin continues to develop his allocator and it proves
better than xcfmalloc (and especially if it can replace
zbud as well), we can consider replacing xcfmalloc later.
Until zcache is promoted from staging, I think we have
that flexibility.

(Shameless advertisement though:  The xcfmalloc allocator
only applies to pages passed via frontswap, and on
that other lkml thread lurk many people intent on shooting
frontswap down.  So, frankly, I'd prefer time to be spent
on benchmarking zcache rather than on arguing about
allocators which, as things currently feel to me on that
other lkml thread, is not unlike rearranging deck chairs
on the Titanic. Half-:-).

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
