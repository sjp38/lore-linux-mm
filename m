Subject: [BUG] [2.6.2-rc2-mm1] Badness in try_to_wake_up at
	kernel/sched.c:722 (was Re: 2.6.2-rc2-mm1)
From: Ramon Rey Vicente <rrey@ranty.pantax.net>
Reply-To: ramon.rey@hispalinux.es
In-Reply-To: <20040127233402.6f5d3497.akpm@osdl.org>
References: <20040127233402.6f5d3497.akpm@osdl.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Wg0z+0FbvvrguZuvtRhz"
Message-Id: <1075309345.1652.5.camel@debian>
Mime-Version: 1.0
Date: Wed, 28 Jan 2004 18:02:26 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Peter Lieverdink <peter@cc.com.au>, Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
List-ID: <linux-mm.kvack.org>

--=-Wg0z+0FbvvrguZuvtRhz
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I get this:

swapper 256 waking epiphany: 1261 1266
Badness in try_to_wake_up at kernel/sched.c:722
Call Trace:
 [<c0118379>] try_to_wake_up+0x79/0x1c0
 [<c01242c9>] update_process_times+0x29/0x40
 [<c01246e0>] process_timeout+0x0/0x20
 [<c01184cd>] wake_up_process+0xd/0x20
 [<c01243cf>] run_timer_softirq+0xcf/0x1c0
 [<c010bfd0>] handle_IRQ_event+0x30/0x60
 [<c012056c>] do_softirq+0x8c/0xa0
 [<c010c30f>] do_IRQ+0xef/0x120
 [<c0107000>] rest_init+0x0/0x60
 [<c023f588>] common_interrupt+0x18/0x20
 [<c0108bc0>] default_idle+0x0/0x40
 [<c0107000>] rest_init+0x0/0x60
 [<c0108be3>] default_idle+0x23/0x40
 [<c0108c65>] cpu_idle+0x25/0x40
 [<c02ca6eb>] start_kernel+0x12b/0x140

and this:

gthumb 0 waking gthumb: 1626 1643
Badness in try_to_wake_up at kernel/sched.c:722
Call Trace:
 [<c0118379>] try_to_wake_up+0x79/0x1c0
 [<c0119404>] __wake_up_common+0x24/0x60
 [<c011945c>] __wake_up+0x1c/0x40
 [<c012e96d>] wake_futex+0x2d/0x60
 [<c012ea59>] futex_wake+0xb9/0xc0
 [<c012f1a7>] do_futex+0x67/0x80
 [<c012f2a8>] sys_futex+0xe8/0x120
 [<c023f367>] syscall_call+0x7/0xb
--=20
Ram=C3=B3n Rey Vicente       <ramon dot rey at hispalinux dot es>
        jabber ID       <rreylinux at jabber dot org>
GPG public key ID 	0xBEBD71D5 -> http://pgp.escomposlinux.org/

--=-Wg0z+0FbvvrguZuvtRhz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Esta parte del mensaje =?ISO-8859-1?Q?est=E1?= firmada
	digitalmente

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAF+shRGk68b69cdURAgJrAJ9zg0c0OctIc3NlY/618GDA26RG5wCfTgk1
zUI06AZqrEs6JkLaTW+YHmI=
=8AIH
-----END PGP SIGNATURE-----

--=-Wg0z+0FbvvrguZuvtRhz--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
