Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 446E86B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 10:26:27 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so4912403vcb.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 07:26:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
	<CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.com>
Date: Fri, 28 Oct 2011 17:26:24 +0300
Message-ID: <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyclonus J <cyclonusj@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 10:30 AM, Cyclonus J <cyclonusj@gmail.com> wrote:
>> I felt it would be difficult to try and merge any tmem KVM patches until
>> both frontswap and cleancache are in the kernel, thats why the
>> development is currently paused at the POC level.
>
> Same here. I am working a KVM support for Transcedent Memory as well.
> It would be nice to see this in the mainline.

We don't really merge code for future projects - especially when it
touches the core kernel.

As for the frontswap patches, there's pretty no ACKs from MM people
apart from one Reviewed-by from Andrew. I really don't see why the
pull request is sent directly to Linus...

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
