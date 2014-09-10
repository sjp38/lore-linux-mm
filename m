Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB916B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 04:10:07 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so5292174pad.9
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:10:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v1si15961549pdf.4.2014.09.10.01.10.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 01:10:06 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:10:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers for
 scanner thread
Message-ID: <20140910081000.GN6758@twins.programming.kicks-ass.net>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
 <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
 <alpine.LSU.2.11.1408272258050.10518@eggly.anvils>
 <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils>
 <20140908093949.GZ6758@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xwQtY96q3287+Drf"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409091225310.8432@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>


--xwQtY96q3287+Drf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 09, 2014 at 01:14:50PM -0700, Hugh Dickins wrote:
> On Mon, 8 Sep 2014, Peter Zijlstra wrote:
> > >  		switch_mm(oldmm, mm, next);
> > > +		wake_ksm =3D ksm_switch(mm);
> >=20
> > Is this the right mm?
>=20
> It's next->mm, that's the one I intended (though the patch might
> be equally workable using prev->mm instead: given free rein, I'd
> have opted for hooking into both prev and next, but free rein is
> definitely not what should be granted around here!).
>=20
> > We've just switched the stack,
>=20
> I thought that came in switch_to() a few lines further down,
> but don't think it matters for this.

Ah, yes. Got my task and mm separation messed up.

> > so we're looing at next->mm when we switched away from current.
> > That might not exist anymore.
>=20
> I fail to see how that can be.  Looking at the x86 switch_mm(),
> I can see it referencing (unsurprisingly!) both old and new mms
> at this point, and no reference to an mm is dropped before the
> ksm_switch().  oldmm (there called mm) is mmdropped later in
> finish_task_switch().

Well, see the above confusion about switch_mm vs switch_to :-/

So if this were switch_to(), we'd see next->mm as before the last
context switch. And since that switch fully happened, it would also
already have done the finish_task_switch() -> mmdrop().



--xwQtY96q3287+Drf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJUEAdYAAoJEHZH4aRLwOS6A1cQAI8Vb0oUNxiFZOGEypnIBrOe
TsRhja+rHPMGJGufjUHB7KM8PPCoQv9h+lsPbVhtHo+S6JQnKS6AFUTgZomuOJrD
9cJOoTOh0fItLH0YsG9lshJngHA7YqszpqcVGhWfu9rWuWWHry1S0NvmW2Eyfg1W
nkGR742Y0T+JFqA0HiNP3/GO+G/EwMX+uW/2bf08igecE9jg0IoiHkA1hai1J1dz
IGdTBn2dkbSX6ibthhvmtGr0oBwKU/64xO6H4OXhXVim3IeSxNbBBsVIhasvTeSp
/Fxy2ptubQsXEuZ8g8R0XX+NXZ6LqycIWteO3qfGyTvttfNN7V0Z3AFxJfno1TZg
qRq/FPNEr55kSK7yaRfoX19kkEbqgC2fO0248fMqc3vmiL+UjFtr7wZUA4NXXsDB
pnJ9ESx7LqgVf0AqaoEjZOL3D+W0iQ2JYi5M7yfNaQRmXA9dlqZc/SeAH0dA4WPZ
pbo415GzR5BDrVZ58H96yw+PUcyMbxJoSD6mR21HUnrjKVsHaqHxk/CV6lKOyItp
k//n4z4HKI2aiBGiqhTCFdYi6XP2waF9C9ASeFWU5u2aDGtcUDtm8rUdWzvXHn7t
v9G0iBg5eiGNwPmJ3CgNOO2VUffBsKCoy9Jq/Pp25phIfi74jmtus0t6mHW8snbk
vdr2QsOjO08nStVEEXY8
=nrfj
-----END PGP SIGNATURE-----

--xwQtY96q3287+Drf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
