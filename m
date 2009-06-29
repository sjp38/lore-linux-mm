Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A39EE6B005A
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 10:34:04 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <0dbec206-c157-4482-8fd7-4ccf9c2bdc5a@default>
Date: Mon, 29 Jun 2009 07:34:34 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <20090624150420.GH1784@ucw.cz>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

Hi Pavel --

Thanks for the feedback!

> This description (whole mail) needs to go into=20
> Documentation/, somewhere.=20

Good idea.  I'll do that for the next time I post the patches.

> > Normal memory is directly addressable by the kernel,
> > of a known normally-fixed size, synchronously accessible,
> > and persistent (though not across a reboot).
> ...
> > Transcendent memory, or "tmem" for short, provides a
> > well-defined API to access this unusual class of memory.
> > The basic operations are page-copy-based and use a flexible
> > object-oriented addressing mechanism.  Tmem assumes
>=20
> Should this API be documented, somewhere? Is it in-kernel API or does
> userland see it?

It is documented currently at:

http://oss.oracle.com/projects/tmem/documentation/api/

(just noticed I still haven't posted version 0.0.2 which
has a few minor changes).

I will add a briefer description of this API in Documentation/

It is in-kernel only because some of the operations have
a parameter that is a physical page frame number.

> > "Preswap" IS persistent, but for various reasons may not always
> > be available for use, again due to factors that may not be
> > visible to the kernel (but, briefly, if the kernel is being
> > "good" and has shared its resources nicely, then it will be
> > able to use preswap, else it will not).  Once a page is put,
> > a get on the page will always succeed.  So when the kernel
> > finds itself in a situation where it needs to swap out a page,
> > it first attempts to use preswap.  If the put works, a disk
> > write and (usually) a disk read are avoided.  If it doesn't,
> > the page is written to swap as usual.  Unlike precache, whether
>=20
> Ok, how much slower this gets in the worst case? Single hypercall to
> find out that preswap is unavailable? I guess that compared to disk
> access that's lost in the noise?

Yes, the overhead of one hypercall per swap page is lost in
the noise.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
