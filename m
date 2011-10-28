Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 876AE6B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 13:02:14 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so5126910vcb.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 09:59:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f0030f74-6c10-4127-beb9-96ef290ecf4c@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
	<CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	<CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	<f0030f74-6c10-4127-beb9-96ef290ecf4c@default>
Date: Fri, 28 Oct 2011 19:59:58 +0300
Message-ID: <CAOJsxLEgwXZAvxfqWN3Ky-7XAHW1zvKS9Owxd_=hdap9iLggVQ@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 7:37 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> Why do you feel that it's OK to ask Linus to pull them?
>
> Frontswap is essentially the second half of the cleancache
> patchset (or, more accurately, both are halves of the
> transcendent memory patchset). =A0They are similar in that
> the hooks in core MM code are fairly trivial and the
> real value/functionality lies outside of the core kernel;
> as a result core MM maintainers don't have much interest
> I guess.

I would not call this commit trivial:

http://oss.oracle.com/git/djm/tmem.git/?p=3Ddjm/tmem.git;a=3Dcommitdiff;h=
=3D6ce5607c1edf80f168d1e1f22dc7a85290cf094a

You are exporting bunch of mm/swapfile.c variables (including locks)
and adding hooks to mm/page_io.c and mm/swapfile.c. Furthermore, code
like this:

> +               if (frontswap) {
> +                       if (frontswap_test(si, i))
> +                               break;
> +                       else
> +                               continue;
> +               }

does not really help your case.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
