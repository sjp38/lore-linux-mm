Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DB8946B002F
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 03:30:14 -0400 (EDT)
Received: by qadc11 with SMTP id c11so4465580qad.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:30:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1319785956.3235.7.camel@lappy>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
Date: Fri, 28 Oct 2011 00:30:10 -0700
Message-ID: <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
From: Cyclonus J <cyclonusj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 12:12 AM, Sasha Levin <levinsasha928@gmail.com> wro=
te:
> On Thu, 2011-10-27 at 17:52 -0400, Christoph Hellwig wrote:
>> On Thu, Oct 27, 2011 at 02:49:31PM -0700, Dan Magenheimer wrote:
>> > If Linux truly subscribes to the "code rules" mantra, no core
>> > VM developer has proposed anything -- even a design, let alone
>> > working code -- that comes close to providing the functionality
>> > and flexibility that frontswap (and cleancache) provides, and
>> > frontswap provides it with a very VERY small impact on existing
>> > kernel code AND has been posted and working for 2+ years.
>> > (And during that 2+ years, excellent feedback has improved the
>> > "kernel-ness" of the code, but NONE of the core frontswap
>> > design/hooks have changed... because frontswap _just works_!)
>>
>> It might work for whatever defintion of work, but you certainly couldn't
>> convince anyone that matters that it's actually sexy and we'd actually
>> need it. =A0Only actually working on Xen of course doesn't help.
>
> Theres a working POC of it on KVM, mostly based on reusing in-kernel Xen
> code.
>
> I felt it would be difficult to try and merge any tmem KVM patches until
> both frontswap and cleancache are in the kernel, thats why the
> development is currently paused at the POC level.

Same here. I am working a KVM support for Transcedent Memory as well.
It would be nice to see this in the mainline.

Thanks,
CJ

>
> --
>
> Sasha.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
