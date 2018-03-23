Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59F686B0009
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:48:05 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p202-v6so4186092lfe.3
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:48:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor2445612lja.82.2018.03.23.10.48.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 10:48:04 -0700 (PDT)
From: Ilya Smith <blackzert@gmail.com>
Message-Id: <5D55B1FC-1962-4941-BF56-1F83554FC64C@gmail.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_B9437F76-CEDD-4524-828D-E63FF8E38C7F";
	protocol="application/pgp-signature";
	micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH v2 2/2] Architecture defined limit on memory region
 random shift.
Date: Fri, 23 Mar 2018 20:48:00 +0300
In-Reply-To: <20180322135448.046ada120ecd1ab3dd8f94aa@linux-foundation.org>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <1521736598-12812-3-git-send-email-blackzert@gmail.com>
 <20180322135448.046ada120ecd1ab3dd8f94aa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, steve.capper@arm.com, punit.agrawal@arm.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, Kees Cook <keescook@chromium.org>, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>


--Apple-Mail=_B9437F76-CEDD-4524-828D-E63FF8E38C7F
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_302D41D8-B8D8-4A57-A90C-AE132EC44462"


--Apple-Mail=_302D41D8-B8D8-4A57-A90C-AE132EC44462
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On 22 Mar 2018, at 23:54, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
>=20
> Please add changelogs.  An explanation of what a "limit on memory
> region random shift" is would be nice ;) Why does it exist, why are we
> doing this, etc.  Surely there's something to be said - at present =
this
> is just a lump of random code?
>=20
Sorry, my bad. The main idea of this limit is to decrease possible =
memory
fragmentation. This is not so big problem on 64bit process, but really =
big for
32 bit processes since may cause failure memory allocation. To control =
memory
fragmentation and protect 32 bit systems (or architectures) this limit =
was
introduce by this patch. It could be also moved to CONFIG_ as well.



--Apple-Mail=_302D41D8-B8D8-4A57-A90C-AE132EC44462
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><blockquote type=3D"cite" class=3D""><div class=3D"">On =
22 Mar 2018, at 23:54, Andrew Morton &lt;<a =
href=3D"mailto:akpm@linux-foundation.org" =
class=3D"">akpm@linux-foundation.org</a>&gt; wrote:</div><br =
class=3D"Apple-interchange-newline"><div class=3D""><div class=3D""><br =
class=3D"">Please add changelogs. &nbsp;An explanation of what a "limit =
on memory<br class=3D"">region random shift" is would be nice ;) Why =
does it exist, why are we<br class=3D"">doing this, etc. &nbsp;Surely =
there's something to be said - at present this<br class=3D"">is just a =
lump of random code?<br class=3D""><br =
class=3D""></div></div></blockquote><div style=3D"margin: 0px; =
font-stretch: normal; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">Sorry, =
my bad. The main idea of this limit is to decrease possible =
memory&nbsp;</span></div><div style=3D"margin: 0px; font-stretch: =
normal; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">fragmentation. This is not so big problem on 64bit process, =
but really big for&nbsp;</span></div><div style=3D"margin: 0px; =
font-stretch: normal; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">32 bit =
processes since may cause failure memory allocation. To control =
memory&nbsp;</span></div><div style=3D"margin: 0px; font-stretch: =
normal; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">fragmentation and protect 32 bit systems (or architectures) =
this limit was&nbsp;</span></div><div style=3D"margin: 0px; =
font-stretch: normal; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">introduce=
 by this patch. It could be also moved to CONFIG_ as =
well.</span></div><div style=3D"margin: 0px; font-stretch: normal; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D""><br =
class=3D""></span></div><div style=3D"margin: 0px; font-stretch: normal; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D""><br =
class=3D""></span></div></div></body></html>=

--Apple-Mail=_302D41D8-B8D8-4A57-A90C-AE132EC44462--

--Apple-Mail=_B9437F76-CEDD-4524-828D-E63FF8E38C7F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEju7OBNw5xIMUzNy9WTzOquRR3DcFAlq1PdAACgkQWTzOquRR
3Ddp9BAAmPUV7u9gSEqLavwAr5Hu+ZmmSJS7i95PzubMqxmQosuS52Z4/bUbBubG
rpcg0eym8hpSfWnUs+SyF4od/d1elKMcF0Xy16b48F7xeGARHOBsxp2WXVdLDxVN
veTQKZ5skp9MHHAPJZbrwJqslKksWdisVWxx14XXWt3o+LqeG5/O7XORxC4zqAEv
wa4BvuDBg86I6/J+5+8aMVeucisrk/DKxG1sWWXWsRkQYDK8+V1pO0RUuxDSHu9K
5YDyvXzdcXy1NML+LAmtPO9xDK+6jI0YVFY6Ifp1wbVYI5KwDLWiAchEYPnHTmcI
719Wfy9aLBVnG8EyOCR1z86LegVJ0AKUidWovh+fhOZ3kO8rbmr9yv7FV0WXzf98
1HUZBQWwW3UuDOb3t/83TMeNHtq/kb0NXD+bjb4NFJUnYS15lYDe9YPhO5MKCudT
X0prbA/oipnJQojAzlITFNUt2N7N+53OxDEdXHzrQDuT0g/wdheM5q27VvQ+EdE5
72YRH72brGkh+b/QhreLK3OjiGa6AWdWpqr+5ERn4TVt1IRBSfRAq5zHAxgDk97S
81cRvJgLR0n2NEXHNrvyjIZebfLuc5CmPiTs4tLHpDYnrrUZtsuQyXk53hSiUmGs
KzBn/WKQGxswsjPNqzFNDNIaf67VXSlf4QQmegh2Fl8GGC8v8pg=
=6qWL
-----END PGP SIGNATURE-----

--Apple-Mail=_B9437F76-CEDD-4524-828D-E63FF8E38C7F--
