Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 495F29000BD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:47:30 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6713c9ef-0d16-45f2-aac7-643c40fd92f8@default>
Date: Tue, 28 Jun 2011 14:47:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] drivers/staging/zcache: support multiple clients, prep
 for RAMster and KVM
References: <cc182d60-216c-4ab5-8fcd-b61cedc4fbd4@default
 20110627160622.GM6978@dumpdata.com>
In-Reply-To: <20110627160622.GM6978@dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@linuxdriverproject.org, linux-mm <linux-mm@kvack.org>, kvm@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>

> From: Konrad Rzeszutek Wilk

Hi Konrad --

Thanks for the review!

> Subject: Re: [PATCH] drivers/staging/zcache: support multiple clients, pr=
ep for RAMster and KVM
>=20

> > +int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t i=
ndex,
> > +=09=09char *data, size_t *size, bool raw, int get_and_free)
>=20
> And also here.. make get_and_free be bool?

This is actually a tri-state so can't be a bool.  The
other variables, as you pointed out, should be bool.
I will fix them and clarify the other two items and
post another version (and I'll remember to cc lkml
this time too ;-)

Thanks again,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
