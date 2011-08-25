Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5BF8D6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 11:09:53 -0400 (EDT)
Date: Fri, 26 Aug 2011 01:09:38 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-Id: <20110826010938.5795e43137d58c9f42d44458@canb.auug.org.au>
In-Reply-To: <20110825140701.GA6838@tiehlicka.suse.cz>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
	<20110825135103.GA6431@tiehlicka.suse.cz>
	<20110825140701.GA6838@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__26_Aug_2011_01_09_38_+1000_ujMjDg7mnHSDn1op"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Fri__26_Aug_2011_01_09_38_+1000_ujMjDg7mnHSDn1op
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, 25 Aug 2011 16:07:01 +0200 Michal Hocko <mhocko@suse.cz> wrote:
>
> On Thu 25-08-11 15:51:03, Michal Hocko wrote:
> >=20
> > On Wed 24-08-11 14:09:05, Andrew Morton wrote:
> > > The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> > >=20
> > >    http://userweb.kernel.org/~akpm/mmotm/
> >=20
> > I have just downloaded your tree and cannot quilt it up. I am getting:
> > [...]
> > patching file tools/power/cpupower/debug/x86_64/centrino-decode.c
> > Hunk #1 FAILED at 1.
> > File tools/power/cpupower/debug/x86_64/centrino-decode.c is not empty a=
fter patch, as expected
> > 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x8=
6_64/centrino-decode.c
> > patching file tools/power/cpupower/debug/x86_64/powernow-k8-decode.c
> > Hunk #1 FAILED at 1.
> > File tools/power/cpupower/debug/x86_64/powernow-k8-decode.c is not empt=
y after patch, as expected
> > 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x8=
6_64/powernow-k8-decode.c
> > [...]
> > patching file virt/kvm/iommu.c
> > Patch linux-next.patch does not apply (enforce with -f)
> >=20
> > Is this a patch (I am using 2.6.1) issue? The failing hunk looks as
> > follows:
> > --- a/tools/power/cpupower/debug/x86_64/centrino-decode.c
> > +++ /dev/null
> > @@ -1 +0,0 @@
> > -../i386/centrino-decode.c
> > \ No newline at end of file
>=20
> Isn't this just a special form of git (clever) diff to spare some lines
> when the file deleted? Or is the patch simply corrupted?
> Anyway, my patch doesn't cope with that. Any hint what to do about it?

Those files were symlinks and were removed by a commit in linux-next.
diff/patch does not cope with that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__26_Aug_2011_01_09_38_+1000_ujMjDg7mnHSDn1op
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOVmWyAAoJEDMEi1NhKgbs75AH/A3x9LCzxwTMuras0QnnmMVe
Q/sLpor2/5ArNwhR4S2+Ohc/36c/6twzE3h4QCO0+2M8BUCAC2pcN9H9/0seb6UX
qdYYROV10Y8O3yF15iSYQzP+iaky5bcpGUG29rHecb6DkUnKfzl8RKF73kJP0H4p
wfXR7uljsZYj5M++mKY+ma3LVD/cwBe0Ycpv5aYDYs2dFE+LP2n6p3BYTW7tBWkC
gEb1k7YR7YCIPraLd8X9T5+jdl3NyUZOs+B+viCwnFms4RCcM9mS1dlxVnUH0+56
3z+OlrOHLZrq0ohKrpeAjj3acTPxEAPA5GU0fiHBYHUDCYMLavC8n64vOBm0R2Q=
=g9BK
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Aug_2011_01_09_38_+1000_ujMjDg7mnHSDn1op--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
