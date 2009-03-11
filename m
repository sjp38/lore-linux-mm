Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E49396B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:05:45 -0400 (EDT)
Date: Wed, 11 Mar 2009 14:05:33 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311140533.3d3d6912@mjolnir.ossman.eu>
In-Reply-To: <20090311082038.GA32129@localhost>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
	<20090310212118.7bf17af6@mjolnir.ossman.eu>
	<20090311013739.GA7078@localhost>
	<20090311075703.35de2488@mjolnir.ossman.eu>
	<20090311071445.GA13584@localhost>
	<20090311082658.06ff605a@mjolnir.ossman.eu>
	<20090311073619.GA26691@localhost>
	<20090311085738.4233df4e@mjolnir.ossman.eu>
	<20090311082038.GA32129@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-29370-1236776739-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-29370-1236776739-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 16:20:38 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

>=20
> There are some __get_free_page() calls in kernel/trace/ring_buffer.c,
> maybe the pages are consumed by one of them?
>=20

Perhaps. I enabled CONFIG_SYSPROF_TRACER (which pulls in
ring_buffer.c). That made the "noflags" memory disappear, but the "lru"
section is not there. I.e. I've lost about 80 MB instead of 170 MB.

The diff against the fully broken conf is now:

@@ -3677,17 +3640,16 @@
 # CONFIG_BACKTRACE_SELF_TEST is not set
 # CONFIG_LKDTM is not set
 # CONFIG_FAULT_INJECTION is not set
-CONFIG_LATENCYTOP=3Dy
+# CONFIG_LATENCYTOP is not set
 # CONFIG_SYSCTL_SYSCALL_CHECK is not set
 CONFIG_HAVE_FTRACE=3Dy
 CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
-CONFIG_TRACER_MAX_TRACE=3Dy
 CONFIG_TRACING=3Dy
 # CONFIG_FTRACE is not set
-CONFIG_IRQSOFF_TRACER=3Dy
+# CONFIG_IRQSOFF_TRACER is not set
 CONFIG_SYSPROF_TRACER=3Dy
-CONFIG_SCHED_TRACER=3Dy
-CONFIG_CONTEXT_SWITCH_TRACER=3Dy
+# CONFIG_SCHED_TRACER is not set
+# CONFIG_CONTEXT_SWITCH_TRACER is not set
 # CONFIG_FTRACE_STARTUP_TEST is not set
 CONFIG_PROVIDE_OHCI1394_DMA_INIT=3Dy
 # CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set


Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-29370-1236776739-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm3tyAACgkQ7b8eESbyJLgvlACffpZyHkKxIgTRU6+LpS1Kua0H
xi4AoIXYSSbfsWQroHvi62IKT93mXqUg
=OadP
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-29370-1236776739-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
