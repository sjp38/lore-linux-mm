Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0296B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 13:01:45 -0400 (EDT)
Received: by vws16 with SMTP id 16so4940345vws.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 10:01:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111028163053.GC1319@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
	<CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	<552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	<CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	<20111028163053.GC1319@redhat.com>
Date: Fri, 28 Oct 2011 20:01:43 +0300
Message-ID: <CAOJsxLEGnpuwmrhO0QJFuOoh5itYFyphtyg+VGH0qdrGH=8zYw@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 7:30 PM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> People did look at it.
>
> In my case, the handwavy benefits did not convince me. =A0The handwavy
> 'this is useful' from just more people of the same company does not
> help, either.
>
> I want to see a usecase that tangibly gains from this, not just more
> marketing material. =A0Then we can talk about boring infrastructure and
> adding hooks to the VM.
>
> Convincing the development community of the problem you are trying to
> solve is the undocumented part of the process you fail to follow.

Indeed. I don't also understand why this is useful nor am I convinced
enough to actually try to figure out how to do the swapfile hooks
cleanly.

                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
