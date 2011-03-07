Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8069A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:13:21 -0500 (EST)
Received: by qwd7 with SMTP id 7so4560738qwd.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 12:13:18 -0800 (PST)
Date: Mon, 7 Mar 2011 15:13:14 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
Message-ID: <20110307201314.GA5354@mgebm.net>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
 <1299527214.8493.13263.camel@nimitz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <1299527214.8493.13263.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 07 Mar 2011, Dave Hansen wrote:

> On Mon, 2011-03-07 at 14:05 +0100, Petr Holasek wrote:
> > +       for_each_hstate(h)
> > +               seq_printf(m,
> > +                               "HugePages_Total:   %5lu\n"
> > +                               "HugePages_Free:    %5lu\n"
> > +                               "HugePages_Rsvd:    %5lu\n"
> > +                               "HugePages_Surp:    %5lu\n"
> > +                               "Hugepagesize:   %8lu kB\n",
> > +                               h->nr_huge_pages,
> > +                               h->free_huge_pages,
> > +                               h->resv_huge_pages,
> > +                               h->surplus_huge_pages,
> > +                               1UL << (huge_page_order(h) + PAGE_SHIFT=
 - 10));
> >  }
>=20
> It sounds like now we'll get a meminfo that looks like:
>=20
> ...
> AnonHugePages:    491520 kB
> HugePages_Total:       5
> HugePages_Free:        2
> HugePages_Rsvd:        3
> HugePages_Surp:        1
> Hugepagesize:       2048 kB
> HugePages_Total:       2
> HugePages_Free:        1
> HugePages_Rsvd:        1
> HugePages_Surp:        1
> Hugepagesize:    1048576 kB
> DirectMap4k:       12160 kB
> DirectMap2M:     2082816 kB
> DirectMap1G:     2097152 kB
>=20
> At best, that's a bit confusing.  There aren't any other entries in
> meminfo that occur more than once.  Plus, this information is available
> in the sysfs interface.  Why isn't that sufficient?
>=20
> Could we do something where we keep the default hpage_size looking like
> it does now, but append the size explicitly for the new entries?
>=20
> HugePages_Total(1G):       2
> HugePages_Free(1G):        1
> HugePages_Rsvd(1G):        1
> HugePages_Surp(1G):        1
>=20
> -- Dave

I second that, this will help minimize the change to userspace tools that c=
urrently read
meminfo for huge page information.

Eric

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNdTxaAAoJEH65iIruGRnNefAIAISv2+UGndFtJT0oHxnZc15C
aXwGi++SjjEzoXjaL1XXaTFyRBW+xAO6YNRgPeJUfnW7c+NLcb2XxffeARkiD5hf
iipzdmTNxndthlYXWwSl+ZCdbcarx+SLdXC7juWVqQe00XXEB5GD/1nEI7E/2l5I
ZcfiCJNDnV3rX8OeEekMm7LBatJ+lkPJj1tnaEW2C9CPwyGiMfl2wqMrT9r9EM0k
OjDX7D7gPE6k9WfSgHKgwmGYwRZu6KWLbEansgf4KZEWlL9qc2DcP4Qip/01t0d2
ZYGESX0gKLv3+t5f2AJAPlM9PMsImRGC3hRPgQfGQvU6GfwRhBga+XM+t65pmKU=
=O0Pi
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
