Content-Type: text/plain;
  charset="iso-8859-1"
From: Scott F. Kaplan <sfkaplan@cs.amherst.edu>
Subject: Re: VM tuning through fault trace gathering [with actual code]
Date: Wed, 27 Jun 2001 08:47:47 -0400
References: <Pine.LNX.4.21.0106270707550.1291-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0106270707550.1291-100000@freak.distro.conectiva>
MIME-Version: 1.0
Message-Id: <0106270847470D.01124@spigot>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Wednesday 27 June 2001 06:09 am, Marcelo Tosatti wrote:
> On 26 Jun 2001, John Fremlin wrote:
> > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> > > ####################################################################
> > > Event     	          Time                   PID     Length Description
> > > ####################################################################
> > >
> > > Trap entry              991,299,585,597,016     678     12      TRAP:
> > > page fault; EIP : 0x40067785
> >
> > That looks like just the generic interrupt handling. It does not do
> > what I want to do, i.e. record some more info about the fault saying
> > where it comes from.
>
> You can create custom events with LTT and then you can get them from a
> "big buffer" to userlevel later, then.

I guess that i have a different concern with this existing utility.  It seems 
that it will report page faults (minor or major) for the normal VM system 
configuration.  What if we want it to record all (or nearly) all page 
references, even ones to pages that *normally* wouldn't cause any kind of 
interrupt?  That ability seems new and unique to John's utility.

(I know, I need to read the LLT manual, as it may be able to do exactly what 
I'm describing.  However, I don't think that's the case.)

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE7OdX28eFdWQtoOmgRAlhHAKCFHjgw62OlQmytkRiY+Zl9xaMz7gCfXSmm
mNsg0QUAwAhJnhwrL088IwI=
=CC+e
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
