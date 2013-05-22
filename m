Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BC46B6B00A4
	for <linux-mm@kvack.org>; Tue, 21 May 2013 20:05:00 -0400 (EDT)
Date: Wed, 22 May 2013 10:04:47 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Finally eradicate CONFIG_HOTPLUG
Message-Id: <20130522100447.0f04799ea138a2f391d38850@canb.auug.org.au>
In-Reply-To: <20130521101349.30660.qmail@stuge.se>
References: <20130521134935.d18c3f5c23485fb5ddabc365@canb.auug.org.au>
	<20130521101349.30660.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__22_May_2013_10_04_47_+1000_=wBw7x16m+7LHjz1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Stuge <peter@stuge.se>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arch@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-pcmcia@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, cluster-devel@redhat.com, linux-mm@kvack.org, Hans Verkuil <hans.verkuil@cisco.com>, Pavel Machek <pavel@ucw.cz>, Doug Thompson <dougthompson@xmission.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Whitehouse <swhiteho@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org

--Signature=_Wed__22_May_2013_10_04_47_+1000_=wBw7x16m+7LHjz1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Peter,

On Tue, 21 May 2013 12:13:49 +0200 Peter Stuge <peter@stuge.se> wrote:
>
> Are you changing the code to have HOTPLUG always -on- or -off- ?
>=20
> From the commit message I had expected always -on-.

Yes, it has been that way for some time.

> Stephen Rothwell wrote:
> > --- a/include/asm-generic/vmlinux.lds.h
> > +++ b/include/asm-generic/vmlinux.lds.h
> > @@ -68,14 +68,6 @@
> >   * are handled as text/data or they can be discarded (which
> >   * often happens at runtime)
> >   */
> > -#ifdef CONFIG_HOTPLUG
> > -#define DEV_KEEP(sec)    *(.dev##sec)
> > -#define DEV_DISCARD(sec)
> > -#else
> > -#define DEV_KEEP(sec)
> > -#define DEV_DISCARD(sec) *(.dev##sec)
> > -#endif
> > -
> >  #ifdef CONFIG_HOTPLUG_CPU
> >  #define CPU_KEEP(sec)    *(.cpu##sec)
> >  #define CPU_DISCARD(sec)
> > @@ -182,8 +174,6 @@
> >  	*(.data)							\
> >  	*(.ref.data)							\
> >  	*(.data..shared_aligned) /* percpu related */			\
> > -	DEV_KEEP(init.data)						\
> > -	DEV_KEEP(exit.data)						\
> ..
> > @@ -503,7 +489,6 @@
> >  /* init and exit section handling */
> >  #define INIT_DATA							\
> >  	*(.init.data)							\
> > -	DEV_DISCARD(init.data)						\
>=20
> Shouldn't the effect of one of the above remain?

As far as I can tell, all references to devinit and devexit have now been
removed from the kernel, so nothing will generate code in these sections
any more, so the linker script no longer needs to deal with them at all.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__22_May_2013_10_04_47_+1000_=wBw7x16m+7LHjz1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRnAujAAoJEECxmPOUX5FE43kP/iMW3Iv5i8CzfoTqtisfnOaO
/Qc/thrqJ07kJBde5H9oybNG82xHc/YS1TH+fOIIcunxwBB/7S6zwTzsfXB93igr
x6IenkWyWgQfZRSi70eiXib3l0FYMhDQJE+cL4QAKpzs2TFta29iwjLpIq/UuCg2
lePFgoYzGCg/ru7zdDRnft6BbhlDXF4XkZoDyUN91fOz4UOUI2JijpKYNT73IbF+
WR8Nql4qLt6PM5c098ON6ZTgxOqD5RfW78Yrvc6diiEpFkJR7qoK1ZwBspUGjrAL
WXP5GypWkjr1nptwuGVHs/z5Ys/YA49bnB43DVFkr3Srr5yqioTykgVADeReu743
jclJU2pAATg8xcAytGChbS7/6oQu/QyzmkbzSVQ2n/ksjNZ1XFYKwm0HRQEMG7tu
jJ2qyqFiCz235RG4W1wzY/aTnJAttbhU10Z4q/uRukSCNWPU/l5RxsS/Ht3D4TSg
Wrr/sWV7dyU57HIhWbSdNkTo0vTu9eCOLZxfAHEES7IDyALPlqWiMsbhwjK4Eu2M
XiXrrJYTlMWzODDpmppZtfZ6ilqXufO7Rf/8A8Tmu8RMlMGC3+7IEsfWnWNARV+2
6WU6RZZ3xZTWkj6x7/mqFYWCOIEvVt80H+6OP+IdLzHixsgA63wSDyqk8bKbH7hb
HssnJPfgyuLYX5tQPgac
=CHuz
-----END PGP SIGNATURE-----

--Signature=_Wed__22_May_2013_10_04_47_+1000_=wBw7x16m+7LHjz1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
