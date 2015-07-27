Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id F3A346B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 09:41:28 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so39355140qkd.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 06:41:28 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id d197si20852501qhc.108.2015.07.27.06.41.27
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 06:41:27 -0700 (PDT)
Date: Mon, 27 Jul 2015 09:41:26 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5 5/7] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150727134126.GB17133@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-6-git-send-email-emunson@akamai.com>
 <20150727073129.GE11657@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Content-Disposition: inline
In-Reply-To: <20150727073129.GE11657@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Jul 2015, Kirill A. Shutemov wrote:

> On Fri, Jul 24, 2015 at 05:28:43PM -0400, Eric B Munson wrote:
> > The cost of faulting in all memory to be locked can be very high when
> > working with large mappings.  If only portions of the mapping will be
> > used this can incur a high penalty for locking.
> >=20
> > Now that we have the new VMA flag for the locked but not present state,
> > expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.
>=20
> As I mentioned before, I don't think this interface is justified.
>=20
> MAP_LOCKED has known issues[1]. The MAP_LOCKED problem is not necessary
> affects MAP_LOCKONFAULT, but still.
>=20
> Let's not add new interface unless it's demonstrably useful.
>=20
> [1] http://lkml.kernel.org/g/20150114095019.GC4706@dhcp22.suse.cz

I understand and should have been more explicit.  This patch is still
included becuase I have an internal user that wants to see it added.
The problem discussed in the thread you point out does not affect
MAP_LOCKONFAULT because we do not attempt to populate the region with
MAP_LOCKONFAULT.

As I told Vlastimil, if this is a hard NAK with the patch I can work
with that.  Otherwise I prefer it stays.


--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVtjUGAAoJELbVsDOpoOa9FEQP/0tZqvE9r1cDWHP2fRNfVeMA
4SA6NwWvWAlS3Jyzwqin6jEPfTp5mp9XmBs2OSFCUtRM4gheS+V0qm4UMCoUUe8V
1biXRm6JAcqlQ9RaQsIleuwtu6rfq/VmPvyXfoh2VzHtHkfJH1es+IuzyMvN8rB2
+dMOrDXpr0TGzV2pUXmpqvJV9XCuJJqC2EUp3ygCjCsxtir7que+hBurNHk6V37o
SJPg+1fOfKlZC2JoH1e3nlaNa8E7Tgn3CcaS95PJGtjp3B3B/WFHyQsV7ICDCPph
p1DS8lNn1AHvC8Ia1b9q9k6iuPVpunFRthVyXLfDtb7UVDxyDBAbBArQMlSqdS98
7s+Am4nRAqQ4hyvCrfFbkXyplihX34uwmi263r7pAPizwJRx/ArnJk+EJK6Qclp+
aiL2BO8PJR2vPi7BfsPSBcgd68iEeCCsOpNGD3GyQ3C5tdtZK/MaDmZm2cCdzaZg
pWkEgj3oi8jiTD59NskpqqsmtWahucR6HVXAF6DNvZXypigq+uvnaqImEOxpOEQR
h1zR5O8L5jnZO1BYAHpJO1+16ZAPcNa2tF20OcxsAvcGvblbFNYG1jzAE6w9FGbz
Qr4VU8B1u/IiDGuHNroiwrTOlN7Tn7wYN0/bstOPk3UavEmg3wEuOaaQat2CU7pC
rLymWmGP9Rc0+NgO/vMz
=Leis
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
