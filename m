Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5FD6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 04:11:05 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so4810992pdb.13
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 01:11:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id kn11si2835351pbd.215.2014.08.07.01.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Aug 2014 01:11:04 -0700 (PDT)
Date: Thu, 7 Aug 2014 10:10:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
Message-ID: <20140807081047.GH19379@twins.programming.kicks-ass.net>
References: <20140805130646.GZ19379@twins.programming.kicks-ass.net>
 <CALFYKtAVQ9Rgu_QWCqUkNHk4-wbiVK0FeiwLDttaxZC5bnnG5w@mail.gmail.com>
 <20140806083134.GQ9918@twins.programming.kicks-ass.net>
 <20140806.141603.1422005306896590750.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nBPD9h0elHGaLLTu"
Content-Disposition: inline
In-Reply-To: <20140806.141603.1422005306896590750.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: ilya.dryomov@inktank.com, mingo@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, tglx@linutronix.de, umgwanakikbuti@gmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org


--nBPD9h0elHGaLLTu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2014 at 02:16:03PM -0700, David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed, 6 Aug 2014 10:31:34 +0200
>=20
> > On Wed, Aug 06, 2014 at 11:51:29AM +0400, Ilya Dryomov wrote:
> >=20
> >> OK, this one is a bit different.
> >>=20
> >> WARNING: CPU: 1 PID: 1744 at kernel/sched/core.c:7104 __might_sleep+0x=
58/0x90()
> >> do not call blocking ops when !TASK_RUNNING; state=3D1 set at [<ffffff=
ff81070e10>] prepare_to_wait+0x50 /0xa0
> >=20
> >>  [<ffffffff8105bc38>] __might_sleep+0x58/0x90
> >>  [<ffffffff8148c671>] lock_sock_nested+0x31/0xb0
> >>  [<ffffffff81498aaa>] sk_stream_wait_memory+0x18a/0x2d0
> >=20
> > Urgh, tedious. Its not an actual bug as is. Due to the condition check
> > in sk_wait_event() we can call lock_sock() with ->state !=3D TASK_RUNNI=
NG.
> >=20
> > I'm not entirely sure what the cleanest way is to make this go away.
> > Possibly something like so:
>=20
> If you submit this formally to netdev with a signoff I'm willing to apply
> this if it helps the debug infrastructure.

Thanks, for now I'm just collecting things to see how far I can take
this. But I'll certainly include you and netdev on a next posting.

--nBPD9h0elHGaLLTu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT4zSCAAoJEHZH4aRLwOS6drwP/Rqu531RhKIbPZ9wf1O+ABhh
5qdSyPXKToCclNZVU9EiFKiyiFA1il6jPUGssfT9/oxjs5Kr7u08OampiMlySr91
2E+SH+Aep+vT78ZeVgWupUHkMk/mmwW0xCDlCs5Xi2bFrreNu12BKfaXtPA1BSdA
vmWaLe5R4qVOEX+Jjt3dSPiLSlTwRooyXTvc5NangOubciIJ/XBsLIV+3yTy+2xj
pe92fxcKCFC61SlpdP1T3po5UzEUK0Wb8Pfn7jDVTwhhBpWpgjOCYsbauYpvGgUC
urQRk69LQzgy8090ldiATK6ITV/JNOlo+XQSfhNwWPb91P3Z2AtJG5oEZIDRYmux
O8vMQdpe9k14KJwLkBDiUTat5nH30xjI0Dmyr8W19hV/X4AwiBUI+JdrCUBt21h4
GvtrdTUu7MndUzfpjq+JMORzZY5NL6VbHfJxrOrHaJK5F3pE7kMZs/yTxm+Wu3HK
96UjmZ/B9orJ9hIdGp+SWM5t/AfxpjRUxHNBG2FxMo0WSN7+qMC+hf8yf/YBKMrv
/YWB3LfCBhr3ovHKBKKP0Z8W/Z5eeFKCdsqdNyeLr4hksKbLqFNP1wLs+uD98Zqq
eQQSz7b6irtT7uSKbrp+wfzblXG4AkJUezgfLLKTuqy6yvVmfbCa9pKUD5+tC1FG
A6pazvhVIT9BiSsahp9T
=pnaO
-----END PGP SIGNATURE-----

--nBPD9h0elHGaLLTu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
