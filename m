Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 341866B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 21:18:21 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id h191so1937346lfg.18
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 18:18:21 -0800 (PST)
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org. [194.107.17.57])
        by mx.google.com with ESMTP id t199si4539512lff.456.2018.02.26.18.18.19
        for <linux-mm@kvack.org>;
        Mon, 26 Feb 2018 18:18:19 -0800 (PST)
Date: Tue, 27 Feb 2018 05:18:18 +0300
From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH v5 0/4] vm: add a syscall to map a process memory into a
 pipe
Message-ID: <20180227021818.GA31386@altlinux.org>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
In-Reply-To: <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 26, 2018 at 12:02:25PM +0300, Pavel Emelyanov wrote:
> On 02/21/2018 03:44 AM, Andrew Morton wrote:
> > On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.c=
om> wrote:
> >=20
> >> This patches introduces new process_vmsplice system call that combines
> >> functionality of process_vm_read and vmsplice.
> >=20
> > All seems fairly strightforward.  The big question is: do we know that
> > people will actually use this, and get sufficient value from it to
> > justify its addition?
>=20
> Yes, that's what bothers us a lot too :) I've tried to start with finding=
 out if anyone=20
> used the sys_read/write_process_vm() calls, but failed :( Does anybody kn=
ow how popular
> these syscalls are?

Well, process_vm_readv itself is quite popular, it's used by debuggers nowa=
days,
see e.g.
$ strace -qq -esignal=3Dnone -eprocess_vm_readv strace -qq -o/dev/null cat =
/dev/null


--=20
ldv

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJalL/qAAoJEAVFT+BVnCUIrHEP/iq2COswEmrUt2Wrrcx4Mqug
xxUPCKfBesxnYe660FjWAXJgy9bRGFCl2E8kz3tQ8w4oaDpGpGGfDhu3dwum7RWM
0RGCkXrLNk4/yGj71DMC3UGp+ENkBaKc5Wu9sYh9E1TAZAaPYh5tfC/KYajN+h5h
QXPINyoAxuWWxNUUHW2sCqql6+1UPGBfKxSkGInqnxg9D5wj6bdzH+n8FgqK+Ja7
B2SUFwGw/WeTZ30p7awC/VYN6mNvPZRr7FauReHvx19wUmkOPmXngnzCp1SbgV1l
5DFOIyHQGt4x5kVMHUutf3m073RQtqlJQ1DzmKWKgto6OMK8/+XQP+aa+R0erM7F
ZDGny+5E9Af6Df0FdOfgvb+mo+AswotfXfYO0i5iTBcRz7VOitOgQZspo+cpQLRI
U7kJ1jD+c/9ZEMXU5IpNpHgyyBks1oma0HNaTsUjiOPO1ulPCPoHFhloqtub/p7c
s1glSej43y35Wj/E0RgkQ/aiULAn0les+BYD9TnpJzx/INo3V7FTMmhSJcV7LaWV
aeTb5o8CW/AoiuHgYvy/4tejDnOvlCvmL0HwOfjhqkh9Ja1nSapFWEddCVK9csQK
i2wFwtwyZXAO82qJns3/w63LfEK93KFPomNvwmuxyJLVQzBJ7U2oZ8ISrsnuLlvz
LibEd0Tf9EiL/Ol4kDHY
=M4cN
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
