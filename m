Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 503266B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 12:31:21 -0400 (EDT)
Date: Fri, 28 Oct 2011 18:30:53 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111028163053.GC1319@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 06:36:03PM +0300, Pekka Enberg wrote:
> On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> >> As for the frontswap patches, there's pretty no ACKs from MM people
> >> apart from one Reviewed-by from Andrew. I really don't see why the
> >> pull request is sent directly to Linus...
> >
> > Has there not been ample opportunity (in 2-1/2 years) for other
> > MM people to contribute?  I'm certainly not trying to subvert any
> > useful technical discussion and if there is some documented MM process
> > I am failing to follow, please point me to it.  But there are
> > real users and real distros and real products waiting, so if there
> > are any real issues, let's get them resolved.
> 
> You are changing core kernel code without ACKs from relevant
> maintainers. That's very unfortunate. Existing users certainly matter
> but that doesn't mean you get to merge code without maintainers even
> looking at it.
> 
> Looking at your patches, there's no trace that anyone outside your own
> development team even looked at the patches. Why do you feel that it's
> OK to ask Linus to pull them?

People did look at it.

In my case, the handwavy benefits did not convince me.  The handwavy
'this is useful' from just more people of the same company does not
help, either.

I want to see a usecase that tangibly gains from this, not just more
marketing material.  Then we can talk about boring infrastructure and
adding hooks to the VM.

Convincing the development community of the problem you are trying to
solve is the undocumented part of the process you fail to follow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
