Date: Wed, 27 Jun 2001 10:51:08 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning through fault trace gathering [with actual code]
In-Reply-To: <0106270847470D.01124@spigot>
Message-ID: <Pine.LNX.4.21.0106271050040.1331-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F.Kaplan" <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 27 Jun 2001, Scott F.Kaplan wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On Wednesday 27 June 2001 06:09 am, Marcelo Tosatti wrote:
> > On 26 Jun 2001, John Fremlin wrote:
> > > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> > > > ####################################################################
> > > > Event     	          Time                   PID     Length Description
> > > > ####################################################################
> > > >
> > > > Trap entry              991,299,585,597,016     678     12      TRAP:
> > > > page fault; EIP : 0x40067785
> > >
> > > That looks like just the generic interrupt handling. It does not do
> > > what I want to do, i.e. record some more info about the fault saying
> > > where it comes from.
> >
> > You can create custom events with LTT and then you can get them from a
> > "big buffer" to userlevel later, then.
> 
> I guess that i have a different concern with this existing utility.  It seems 
> that it will report page faults (minor or major) for the normal VM system 
> configuration.  What if we want it to record all (or nearly) all page 
> references, even ones to pages that *normally* wouldn't cause any kind of 
> interrupt?  That ability seems new and unique to John's utility.
> 
> (I know, I need to read the LLT manual, as it may be able to do exactly what 
> I'm describing.  However, I don't think that's the case.)

You are right here. 

But anyway, I think John can do what he wants without writting a whole
new tracing facility. 

IMHO. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
