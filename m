Date: Wed, 18 Aug 2004 08:36:27 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: arch_get_unmapped_area_topdown vs stack reservations
Message-ID: <20040818063627.GA31081@devserv.devel.redhat.com>
References: <170170000.1092781114@flay> <20040818061121.GB21740@devserv.devel.redhat.com> <259380000.1092809909@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <259380000.1092809909@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 17, 2004 at 11:18:30PM -0700, Martin J. Bligh wrote:
> --Arjan van de Ven <arjanv@redhat.com> wrote (on Wednesday, August 18, 2004 08:11:21 +0200):
> 
> > On Tue, Aug 17, 2004 at 03:18:34PM -0700, Martin J. Bligh wrote:
> >> I worry that the current code will allow us to intrude into the 
> >> reserved stack space with a vma allocation if it's requested at
> >> an address too high up. One could argue that they got what they
> >> asked for ... but not sure we should be letting them do that?
> > 
> > well even the non-flexmmap code allows this...
> 
> Yeah, wasn't meant as a criticism of the new layout, just a general
> improvement, perhaps.
> 
> > what is the problem ?
> 
> Just that if they allocate right up to the stack, we'll go boom shortly
> afterwards. I guess the question is ... what exactly are the rules
> for stack space reservations?

well... unless you have a VERY good reason I would see it as rude to prevent
this, I mean, the user *asks* for this address. Posix and co I'm sure don't
allow you to deny it unless it's really busy. 
Or say the user unmaps the stack (after allocating a new one and changing
esp).... the kernel then would not allow a new area to be mapped there
either.... smells like something the kernel should not enforce to me.

--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBIvjqxULwo51rQBIRAlq5AJ4gyTqG1yMVery3UyPxvP2WmopFNgCePkRv
ZI6MyDkopTbzKYtRZ4Dk3qU=
=Ys2g
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
