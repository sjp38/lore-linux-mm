Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C85C08D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 16:46:51 -0400 (EDT)
Subject: Re: mmotm 2011-03-31-14-48 uploaded
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110403181147.AE42.A69D9226@jp.fujitsu.com>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
	 <20110403181147.AE42.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 04 Apr 2011 22:46:31 +0200
Message-ID: <1301949991.2221.5.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

On Sun, 2011-04-03 at 18:11 +0900, KOSAKI Motohiro wrote:
> Ingo, Perter, Is this known issue?
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [    0.169037] divide error: 0000 [#1] SMP
> [    0.169982] last sysfs file:
> [    0.169982] CPU 0
> [    0.169982] Modules linked in:
> [    0.169982]
> [    0.169982] Pid: 1, comm: swapper Not tainted 2.6.39-rc1-mm1+ #2 FUJIT=
SU-SV      PRIMERGY                      /D2559-A1
> [    0.169982] RIP: 0010:[<ffffffff8104ad4c>]  [<ffffffff8104ad4c>] find_=
busiest_group+0x38c/0xd30=20

Not something I've recently seen, so no.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
