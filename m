Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9EEE6B0008
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:38:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l14so5743199pgn.21
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:38:28 -0800 (PST)
Received: from mr26p42im-ztdg06103201.me.com (mr26p42im-ztdg06103201.me.com. [17.111.243.30])
        by mx.google.com with ESMTPS id s19si6964473pfk.260.2018.02.26.08.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 08:38:27 -0800 (PST)
Received: from process-dkim-sign-daemon.mr26p42im-ztdg06103201.me.com by
 mr26p42im-ztdg06103201.me.com
 (Oracle Communications Messaging Server 8.0.1.2.20170607 64bit (built Jun  7
 2017)) id <0P4R00M00NJOOO00@mr26p42im-ztdg06103201.me.com> for
 linux-mm@kvack.org; Mon, 26 Feb 2018 16:38:24 +0000 (GMT)
From: Nathan Hjelm <hjelmn@me.com>
Message-id: <B9A6330F-48FE-4260-A505-3FF043874F0F@me.com>
Content-type: multipart/signed;
 boundary="Apple-Mail=_6A54AC93-1F7E-43B9-A4A6-B8E2291C2347";
 protocol="application/pgp-signature"; micalg=pgp-sha512
MIME-version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [OMPI devel] [PATCH v5 0/4] vm: add a syscall to map a process
 memory into a pipe
Date: Mon, 26 Feb 2018 09:38:19 -0700
In-reply-to: <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Open MPI Developers <devel@lists.open-mpi.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrei Vagin <avagin@openvz.org>, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>, rr-dev@mozilla.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, criu@openvz.org, linux-mm@kvack.org, Greg KH <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, gdb@sourceware.org, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>


--Apple-Mail=_6A54AC93-1F7E-43B9-A4A6-B8E2291C2347
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

All MPI implementations have support for using CMA to transfer data =
between local processes. The performance is fairly good (not as good as =
XPMEM) but the interface limits what we can do with to remote process =
memory (no atomics). I have not heard about this new proposal. What is =
the benefit of the proposed calls over the existing calls?

-Nathan

> On Feb 26, 2018, at 2:02 AM, Pavel Emelyanov <xemul@virtuozzo.com> =
wrote:
>=20
> On 02/21/2018 03:44 AM, Andrew Morton wrote:
>> On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport =
<rppt@linux.vnet.ibm.com> wrote:
>>=20
>>> This patches introduces new process_vmsplice system call that =
combines
>>> functionality of process_vm_read and vmsplice.
>>=20
>> All seems fairly strightforward.  The big question is: do we know =
that
>> people will actually use this, and get sufficient value from it to
>> justify its addition?
>=20
> Yes, that's what bothers us a lot too :) I've tried to start with =
finding out if anyone
> used the sys_read/write_process_vm() calls, but failed :( Does anybody =
know how popular
> these syscalls are? If its users operate on big amount of memory, they =
could benefit from
> the proposed splice extension.
>=20
> -- Pavel
> _______________________________________________
> devel mailing list
> devel@lists.open-mpi.org
> https://lists.open-mpi.org/mailman/listinfo/devel


--Apple-Mail=_6A54AC93-1F7E-43B9-A4A6-B8E2291C2347
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE2GIIdNgp/fA6+otZb+5NXWbsZioFAlqUN/sACgkQb+5NXWbs
Ziqqvg//VVpRs73U8FH12mV10hzJmQEVssOgHVrroVBeg0oRjVFsUp8fJxxvV9iC
DZ+yylG7T5K7V1ixlbv1Uw9nj79CB99HQuTtXARv7Rab2opcWWh2MktEV9+8iM7f
xCXc+JCQfd6ncL/codqUTry+F++1K3fIanRj2/TtK0fr45uNODAPxS8FIxMl5NYg
hym0BEmZkwKm5BKZbWqlDq3ES2HSrIHHXw33liTJcWQSnmsV1KLWMPvJwVWKF/s2
eyrLBASiwbNw+BkZXY3LSqRRXU8pJM1HQo4PKsiMp+caBGypeSgq4WDn6i9vmfFW
qUZmtNYzlnpFLNiFJBIfPYIoYrsondHCDD7U7V2tS+j70hG5/5apj3Mgu4mBBm5L
DQpfyiCPLE6objfpt1qd+fqWTLNpbQAS1elctmxqDL1MgXQXrjMgOrbZJPLUzP5q
6EfTw09wOUjtpl6dmB5g4UvnJztTRTHGTkS/DNl6UhSnGGK7EC442hAhkMjs8/Yh
zbc6/LxXu8B7k5VBopKx8nxISbq00A1Y1loPlsOaKx581RsUaIrpl1bUx3t62QzC
8MbuNZWqj4ogv2VIxJBP3h/YI8Hedzjckzy/aHVkwyj5N+iHjHmXGGPFm/7q9lm/
os5LIAQQ/F5pE1wqZq3EE3XLSXMP8fU2q+YjaVYXr7a+IX4MVbM=
=HLfy
-----END PGP SIGNATURE-----

--Apple-Mail=_6A54AC93-1F7E-43B9-A4A6-B8E2291C2347--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
