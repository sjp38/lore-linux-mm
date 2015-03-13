Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id DD288829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 15:09:21 -0400 (EDT)
Received: by qcrw7 with SMTP id w7so28946090qcr.8
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 12:09:21 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id q17si2721001qha.105.2015.03.13.12.09.20
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 12:09:20 -0700 (PDT)
Date: Fri, 13 Mar 2015 15:09:15 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
Message-ID: <20150313190915.GA12589@akamai.com>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com>
 <550332CE.7040404@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Content-Disposition: inline
In-Reply-To: <550332CE.7040404@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 13 Mar 2015, Rik van Riel wrote:

> On 03/13/2015 01:26 PM, Eric B Munson wrote:
>=20
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1046,6 +1046,8 @@ typedef enum {
> >  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> >  } isolate_migrate_t;
> > =20
> > +int sysctl_compact_unevictable;
> > +
> >  /*
> >   * Isolate all pages that can be migrated from the first suitable bloc=
k,
> >   * starting at the block pointed to by the migrate scanner pfn within
>=20
> I suspect that the use cases where users absolutely do not want
> unevictable pages migrated are special cases, and it may make
> sense to enable sysctl_compact_unevictable by default.

Given that sysctl_compact_unevictable=3D0 is the way the kernel behaves
now and the push back against always enabling compaction on unevictable
pages, I left the default to be the behavior as it is today.  I agree
that this is likely the minority case, but I'd really like Peter Z or
someone else from real time to say that they are okay with the default
changing.

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVAzXbAAoJELbVsDOpoOa9EssQAITn6Nsh9eTl0J8jUrDuC2V2
b0McdIKX1u8DlydKOKUyvJfKxM6XElGVVQZTpQRBS3QPq0mxYztOm6fn+6JVWsJk
QQhfTTiPSfg5BiYHC6SuyAIarEoOzgC6DCKnMddND/tvjQ4j/e/wlxjYjASO+IpI
xo0EVRt7BUCoj/fyoPKRyDtFlAs+GAXdOQ2JCGlcVv9msSemtHO/JSgCF+ffXhlF
G1JXYaHpdH7xkuRaXHun0qea8BueA4FZpjsfZPG9OVX83aHU8wRDCmZBLguIyJQf
XYpvItbUmIo0O5APjPUylYS8IXaQJVOgJjxMVsv2HoZ8J8js7apIGt96Kaw2QbtG
ED3N1YKUiA9ajqehbyNheNUtAUAOWeNVVVGL0NH4oXJtgR1sCxvcu/xPVULoWphH
5TRyTJ/B1xCVuzfCHU9clGrCbORDhgNWpFFzZN8QzY+8CqGbe7fBrtjc4s23ZWJv
QNPscDDdeOlTVnQNLfyWxwKPQ0aE2/NGLjRH7l4nNDEyICwvPYaaQxz44Y7vUv9X
yQZh5s5ESuPcixXRLSGNjLxK97Wg0/DTV75VqGNLDIKEqrHUKIAg/cwfYQhbG4vC
m4sDTDf3btr/NxgnlJ0yD5r4RUpQtecm3hE/YD7U4MCN4vfvLACscADTGmJeMaib
G+at4wC91x0L6x97vtZg
=IOEw
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
