Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3D14C6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 11:12:41 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so39109504pad.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 08:12:41 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id bt1si21578087pbb.171.2015.06.01.08.12.39
        for <linux-mm@kvack.org>;
        Mon, 01 Jun 2015 08:12:40 -0700 (PDT)
Date: Mon, 1 Jun 2015 11:12:39 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150601151239.GA14282@akamai.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Content-Disposition: inline
In-Reply-To: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 01 Jun 2015, Michal Hocko wrote:

> panic_on_oom allows administrator to set OOM policy to panic the system
> when it is out of memory to reduce failover time e.g. when resolving
> the OOM condition would take much more time than rebooting the system.
>=20
> out_of_memory tries to be clever and prevent from premature panics
> by checking the current task and prevent from panic when the task
> has fatal signal pending and so it should die shortly and release some
> memory. This is fair enough but Tetsuo Handa has noted that this might
> lead to a silent deadlock when current cannot exit because of
> dependencies invisible to the OOM killer.
>=20
> panic_on_oom is disabled by default and if somebody enables it then any
> risk of potential deadlock is certainly unwelcome. The risk is really
> low because there are usually more sources of allocation requests and
> one of them would eventually trigger the panic but it is better to
> reduce the risk as much as possible.
>=20
> Let's move check_panic_on_oom up before the current task is
> checked so that the knob value is . Do the same for the memcg in
> mem_cgroup_out_of_memory.
>=20
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

I was initially going to complain about this causing the machine to
panic when a cgroup is oom, but the machine is not.  However after
reading check_panic_on_oom(), that behavior is controllable.

Reviewed-by: Eric B Munson <emunson@akamai.com>


--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVbHZnAAoJELbVsDOpoOa9zd4P/jiiBTF4ehhpmMsnmi4FRUtY
MxSQn12YLu5gXdUJ5Yg0f/qrqbqvJSP7MZ9gWt1Bnt3tVvyXSSUvUzauDnKbiSIm
/nzr7/eQ0xYxCj3QCQCqKqnMMnWnsnwmwHspSKtIi3qdEOELMuDreWBinihgzxmF
Yo/K0Tw32xicSdVrvnev2MwvrebDhrpuAxBfwe+IZf4mcF+ZAfE3kWOO3lNjkBTR
RNKbo5XR8Dgs477ZSYISgJFXh7zHzbuLRGtUmibTKG7KQQOqsg1ec8ogZ/6CM5V0
lsRkh5SszXg0saN2Q7oibEf0BpZk1OBAidVFwVOpMrAvESXCnmmW5qg+wkv3btM4
/+0Ok3nYrVnfcNSxli4IxMrr/WgpGX6k2jNr+sanwx3BAUxiOx2O8PvgqQHPqa36
PJIZnH5WLfkkeYaCtGPypkQLb5VUtK3N3V7C+BHr/su4U0HlEUCxFOoyCEGXHgE1
VVcfWZp4MAW56bhgtut7O+H7Th3WAMbxSGAlYKeR6EXTdKL4WcQAkMUPtZseB7VE
W9Zm8lilmv/HXPlHNXlqXnYqIf1yZbX7ik+Dum8Aa94oGxO0coMkh2ImvEusqqxr
xUB3j6qpBfydYjbpSSpTyob9TOSk9jdc39Eo71Cahz64jd26WXM39avQx9mmFIyb
wM+guHi6EJ22EvdIcb/1
=3ixX
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
