Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id D15DC6B00D8
	for <linux-mm@kvack.org>; Tue, 19 May 2015 13:10:08 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so25464540wgf.2
        for <linux-mm@kvack.org>; Tue, 19 May 2015 10:10:08 -0700 (PDT)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id el3si16696795wid.68.2015.05.19.10.10.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 10:10:07 -0700 (PDT)
Message-ID: <1432055392.12412.34.camel@decadent.org.uk>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 19 May 2015 18:09:52 +0100
In-Reply-To: <20150519151541.GJ6203@dhcp22.suse.cz>
References: <20150519104057.GC2462@suse.de>
	 <20150519141807.GA9788@cmpxchg.org> <20150519144345.GF2462@suse.de>
	 <20150519151541.GJ6203@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jE7Fec7qAhbXZf0Hnv5Q"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Debian kernel maintainers <debian-kernel@lists.debian.org>


--=-jE7Fec7qAhbXZf0Hnv5Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-05-19 at 17:15 +0200, Michal Hocko wrote:
> [Let's CC Ben here - the email thread has started here:
> http://marc.info/?l=3Dlinux-mm&m=3D143203206402073&w=3D2 and it seems Deb=
ian
> is disabling memcg controller already so this might be of your interest]
>=20
> On Tue 19-05-15 15:43:45, Mel Gorman wrote:
> [...]
> > After I wrote the patch, I spotted that Debian apparently already
> > does something like this and by coincidence they matched the
> > parameter name and values. See the memory controller instructions on
> > https://wiki.debian.org/LXC#Prepare_the_host . So in this case at least
> > upstream would match something that at least one distro in the field
> > already uses.
>=20
> I've read through
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D534964 and it seems
> that the primary motivation for the runtime disabling was the _memory_
> overhead of the struct page_cgroup
> (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D534964#152). This is
> no longer the case since 1306a85aed3e ("mm: embed the memcg pointer
> directly into struct page") merged in 3.19.
>=20
> I can see some point in disabling the memcg due to runtime overhead.

I was also concerned about runtime overhead.

> There will always be some, albeit hard to notice. If an user really need
> this to happen there is a command line option for that. The question is
> who would do CONFIG_MEMCG && !MEMCG_DEFAULT_ENABLED.  Do you expect any
> distributions go that way?
> Ben, would you welcome such a change upstream or is there a reason to
> change the Debian kernel runtime default now that the memory overhead is
> mostly gone (for 3.19+ kernels of course)?

I have been meaning to reevaluate this as I know the overhead has been
reduced.  Given Mel's benchmark results, I favour keeping it disabled by
default in Debian.  So I would welcome this change.

Ben.

--=20
Ben Hutchings
I'm not a reverse psychological virus.  Please don't copy me into your sig.

--=-jE7Fec7qAhbXZf0Hnv5Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVVtuZee/yOyVhhEJAQoIMRAAlIH39TrYgnVzaO/Uycqy23LZpvz4el4d
bsjUl6cZM78rlDZJSgcvsHxValZw/0SosW8kvo+S0xzQQLGJGnAFsyoCdtD4k4cj
bxYW3k2yxJAOlzq7yBu6xf2s/rMAn/msyPmjqS9lU+ilvOrsxr38odYJMWY8plF2
MEJ2WTaDrspGDM/VeMQlJDw6nSzckJ7p12LodJbLre0souoxRjDzU+90fYJ5kd8a
DLonrL+kL+HKxjY/jLtaQVTU8EAIRoxTPDSZaX5myTnxwOI6yLmFKg2N3kO7oB8C
aY0pGWD6cjLSxdRwooVmk/Xenzwam1hHWc/12l6XOkaUs43/Xw096mYs9qv3Knhv
UGNluf3Flbz+zMM7dg+UaK9jq1kPEWP/jqty4ICnRlKbSTTOtoTtLRKwAKL5bSj5
CAye+w2m77ipEJ2NxNweEsTCCxaniOvqX+IyDiPzkVTlYChaIWQfsD9hsW2Zc7T5
/2mia5f6iEeWjm/3R2MY697a1XXHj1rHAdVg5Yh0K3LE0nqNvnYZPN8pw0ab8ktz
/PnVFA+ObAn+n+VBahoDdwdR/rwuXm3a5OnT32s0K9uJtOZRj+hrHkMlGVGX1II0
XLi/rBtNn9om3bvs64TX62+8HdD9v3XveeOOcvQEOAuX2MnGjjTAzg9gO4QM0uvL
ZUAZvHEOCRs=
=ZIn5
-----END PGP SIGNATURE-----

--=-jE7Fec7qAhbXZf0Hnv5Q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
