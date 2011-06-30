Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F0C236B0012
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:32:57 -0400 (EDT)
Received: by vxg38 with SMTP id 38so2415255vxg.14
        for <linux-mm@kvack.org>; Thu, 30 Jun 2011 07:32:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110629080827.GA975@phantom.vanrein.org>
References: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
	<532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
	<BANLkTik3mEJGXLrf_XtssfdRypm3NxBKvkhcnUpK=YXV6ux=Ag@mail.gmail.com>
	<20110629080827.GA975@phantom.vanrein.org>
Date: Thu, 30 Jun 2011 15:32:54 +0100
Message-ID: <BANLkTimMFCh+bgF8FaQYUbVrshxUReD_Xw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Jody Belka <jody+lkml@jj79.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: Craig Bergstrom <craigb@google.com>, fa.linux.kernel@googlegroups.com, "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On 29 June 2011 09:08, Rick van Rein <rick@vanrein.org> wrote:
>
> Hello Craig,
>
> > Some folks had mentioned that they're interested in details about what
> > we've learned about bad ram from our fleet of machines. =C2=A0I suspect
> > that you need ACM portal access to read this,
>
> I'm happy that this didn't cause a flame, but clearly this is not the
> right response in an open environment. =C2=A0ACM may have copyright on th=
e
> *form* in which you present your knowledge, but could you please poor
> the knowledge in another form that bypasses their copyright so the
> knowledge is made available to all?

Luckily one of the authors (Bianca Schroeder) has a copy on her
university web space, free for personal/classroom use. Can be found at
http://www.cs.toronto.edu/~bianca/, search for "DRAM errors in the
wild".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
