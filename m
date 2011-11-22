Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EE436B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:50:03 -0500 (EST)
Date: Wed, 23 Nov 2011 01:49:45 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v7 3.2-rc2 0/30] uprobes patchset with perf probe
 support
Message-Id: <20111123014945.5e6cfbf57f7664b3bc1ee2e3@canb.auug.org.au>
In-Reply-To: <20111122050330.GA24807@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	<20111122050330.GA24807@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__23_Nov_2011_01_49_45_+1100_r.z95oFH8_BGr2/S"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>

--Signature=_Wed__23_Nov_2011_01_49_45_+1100_r.z95oFH8_BGr2/S
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Srikar,

On Tue, 22 Nov 2011 10:33:30 +0530 Srikar Dronamraju <srikar@linux.vnet.ibm=
.com> wrote:
>
> > uprobes git is hosted at git://github.com/srikard/linux.git
> > with branch inode_uprobes_v32rc2.
>
> Given that uprobes has been reviewed several times on LKML and all
> comments till now have been addressed, can we push uprobes into either
> -tip or -next. This will help people to test and give more feedback and
> also provide a way for it to be pushed into 3.3. This also helps in
> resolving and pushing fixes faster.

OK, I have added that to linux-next with you as the contact,

> If you have concerns, can you please voice them?

You should tidy up the commit messages (they almost all have really bad
short descriptions) and make sure that the authorship is correct in all
cases.

Also, I would prefer a less version specific branch name (like "for-next"
or something) that way you won't have to keep asking me to change it over
time.  If there is any way you can host this on kernel.org, that will
make the merging into Linus' tree a bit smoother.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Wed__23_Nov_2011_01_49_45_+1100_r.z95oFH8_BGr2/S
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOy7aJAAoJEECxmPOUX5FEezsP/AkfL68lZlV0sVfe8EK08dr6
I+2k9KC3/syUq0IZeZrA+Ld3hnM305NPoiTTMQil0QoH6XcQWlDwDl2/iBvib6qx
MZ6qykvl1RZ1uCzoVIMYOMy/z1ILWVSTp91jp8cz2Aow3lUWtkc1hGgFn/aJhb7L
l3onvvGWNnLJcfYAon5l8nwHtke4vb+efx9VeWBBBkWllVCILiqjxQNCM3l9Tk+V
0aBY39dzWrD6q3qSNVzBJkMvZEoS1pTnXljd7wIfTQGUSR/LbQgouxDAvda04ed2
VS5ngo+y7IDD10QbtI+OJL4F49KAmiuoeIcd7RxyNgOGbkDjrA5r1TwirZV7Rf48
4wOnxvgzTMZPvhzbOaORrCSW0uAGBPJ0SvSL2vRv5BdZUD+sf+l4j2GKJcKEBZe1
jQkWTdVnmuzDIIyVONTM8539uSoIP4vODwLoN/zYcdn08JQ6240RYQ38qcf7AsCR
Xfm7YaoD1VKD8+zJuzJ8P6rUgo+1jtIcCa8CsbKmjJV8vs0hmBxGdzMr/y2oUoSh
fp3fcPiit7tXeclzp/Oiqzz7pl5xL51AcqI769m/mDUDtKT0r2M/ZVpJ05VCPDG+
bEOOJpcTq8oaTGPni+GIafuCI03Zv8xoWtHmAIhpM9mizG2r2eCKnSwnA0YpNGO3
qtGWFEBRzeEnwlW7Hmu+
=r+r3
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Nov_2011_01_49_45_+1100_r.z95oFH8_BGr2/S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
