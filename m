Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 4D79A6B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 09:59:55 -0500 (EST)
From: "Mitchell, Lisa (MCLinux in Fort Collins)" <lisa.mitchell@hp.com>
Subject: RE: [PATCH v2] Add the values related to buddy system for filtering
 free pages.
Date: Fri, 8 Feb 2013 14:59:10 +0000
Message-ID: <D1EE06D5773FD14B8B7BE95DA4B3A74443203BCA@G4W3231.americas.hpqcorp.net>
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
	<20121219161856.e6aa984f.akpm@linux-foundation.org>
	<20121220112103.d698c09a9d1f27a253a63d37@mxc.nes.nec.co.jp>
	<33710E6CAA200E4583255F4FB666C4E20AB2DEA3@G01JPEXMBYT03>
	<87licsrwpg.fsf@xmission.com>
	<20121227173523.5e414c342fed3e59a887fa87@mxc.nes.nec.co.jp>
	<1360240151.12251.15.camel@lisamlinux.fc.hp.com>
 <20130208114509.0755d9012cdfbcbd99c3a4ff@mxc.nes.nec.co.jp>
In-Reply-To: <20130208114509.0755d9012cdfbcbd99c3a4ff@mxc.nes.nec.co.jp>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: "vgoyal@redhat.com" <vgoyal@redhat.com>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "d.hatayama@jp.fujitsu.com" <d.hatayama@jp.fujitsu.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "cpw@sgi.com" <cpw@sgi.com>

Thanks, that's good news, and thanks for the commit ID, that was the thing =
I was having trouble finding.

-----Original Message-----
From: Atsushi Kumagai [mailto:kumagai-atsushi@mxc.nes.nec.co.jp]=20
Sent: Thursday, February 07, 2013 7:45 PM
To: Mitchell, Lisa (MCLinux in Fort Collins)
Cc: vgoyal@redhat.com; kexec@lists.infradead.org; linux-kernel@vger.kernel.=
org; linux-mm@kvack.org; d.hatayama@jp.fujitsu.com; ebiederm@xmission.com; =
akpm@linux-foundation.org; cpw@sgi.com
Subject: Re: [PATCH v2] Add the values related to buddy system for filterin=
g free pages.

Hello Lisa,

On Thu, 07 Feb 2013 05:29:11 -0700
Lisa Mitchell <lisa.mitchell@hp.com> wrote:

> > > > Also, I have one question. Can we always think of 1st and 2nd=20
> > > > kernels are same?
> > >=20
> > > Not at all.  Distros frequently implement it with the same kernel=20
> > > in both role but it should be possible to use an old crusty stable=20
> > > kernel as the 2nd kernel.
> > >=20
> > > > If I understand correctly, kexec/kdump can use the 2nd kernel=20
> > > > different from the 1st's. So, differnet kernels need to do the=20
> > > > same thing as makedumpfile does. If assuming two are same, problem =
is mush simplified.
> > >=20
> > > As a developer it becomes attractive to use a known stable kernel=20
> > > to capture the crash dump even as I experiment with a brand new kerne=
l.
> >=20
> > To allow to use the 2nd kernel different from the 1st's, I think we=20
> > have to take care of each kernel version with the logic included in=20
> > makedumpfile for them. That's to say, makedumpfile goes on as before.
> >=20
> >=20
> > Thanks
> > Atsushi Kumagai
>=20
>=20
> Atsushi and Vivek: =20
>=20
> I'm trying to get the status of whether the patch submitted in
> https://lkml.org/lkml/2012/11/21/90  is going to be accepted upstream
> and get in some version of the Linux 3.8 kernel.   I'm replying to the
> last email thread above on kexec_lists and lkml.org  that I could find=20
> about this patch.
>=20
> I was counting on this kernel patch to improve performance of=20
> makedumpfilev1.5.1, so at least it wouldn't be a regression in
> performance over makedumpfile v1.4.   It was listed as recommended in
> the makedumpfilev1.5.1 release posting:
> http://lists.infradead.org/pipermail/kexec/2012-December/007460.html
>=20
>=20
> All the conversations in the thread since this patch was committed=20
> seem to voice some reservations now, and reference other fixes being=20
> tried to improve performance.
>=20
> Does that mean you are abandoning getting this patch accepted=20
> upstream, in favor of pursuing other alternatives?

No, this patch has been merged into -next, we should just wait for it to be=
 merged into linus tree.

  http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3Dcommi=
t;h=3D0c63e90dd1c7b35ae2ea9475ba67cf68d8801a26

What interests us now is improvement for interfaces of /proc/vmcore, it's n=
ot alternative but another idea which can be consistent with this patch.


Thanks
Atsushi Kumagai

>=20
> I had hoped this patch would be okay to get accepted upstream, and=20
> then other improvements could be built on top of it.
>=20
> Is that not the case?  =20
>=20
> Or has further review concluded now that this change is a bad idea due=20
> to adding dependence of this new makedumpfile feature on some deep=20
> kernel memory internals?
>=20
> Thanks,
>=20
> Lisa Mitchell
>=20
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
