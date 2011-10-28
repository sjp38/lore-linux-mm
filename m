Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 49B826B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 12:02:49 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so5014547vcb.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 08:36:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
	<CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	<552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
Date: Fri, 28 Oct 2011 18:36:03 +0300
Message-ID: <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Hi Dan,

On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> If you grep the 3.1 source for CONFIG_FRONTSWAP, you will find
> two users already in-kernel waiting for frontswap to be merged.
> I think Sasha and Neo (and Brian and Nitin and ...) are simply
> indicating that there can be more, but there is a chicken-and-egg
> problem that can best be resolved by merging the (really very small
> and barely invasive) frontswap patchset.

Yup, I was referring to the two external projects. I also happen to
think that only Xen matters because zcache is in staging. So that's
one user in the tree.

On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> As for the frontswap patches, there's pretty no ACKs from MM people
>> apart from one Reviewed-by from Andrew. I really don't see why the
>> pull request is sent directly to Linus...
>
> Has there not been ample opportunity (in 2-1/2 years) for other
> MM people to contribute? =A0I'm certainly not trying to subvert any
> useful technical discussion and if there is some documented MM process
> I am failing to follow, please point me to it. =A0But there are
> real users and real distros and real products waiting, so if there
> are any real issues, let's get them resolved.

You are changing core kernel code without ACKs from relevant
maintainers. That's very unfortunate. Existing users certainly matter
but that doesn't mean you get to merge code without maintainers even
looking at it.

Looking at your patches, there's no trace that anyone outside your own
development team even looked at the patches. Why do you feel that it's
OK to ask Linus to pull them?

> P.S. before commenting further, I suggest that you read the
> background material at http://lwn.net/Articles/454795/
> (with an open mind :-).

I'm not for or against frontswap. I assume we need something like that
since Xen and KVM folks are interested. That doesn't mean you get a
free pass to add more complexity to the VM.

So really, why don't you just use scripts/get_maintainer.pl and simply
ask the relevant people for their ACK?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
