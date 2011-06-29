Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 87BD26B00F1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 12:06:19 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p5TG6GGo024345
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:06:16 -0700
Received: from gxk26 (gxk26.prod.google.com [10.202.11.26])
	by hpaq3.eem.corp.google.com with ESMTP id p5TG6CYv020809
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:06:15 -0700
Received: by gxk26 with SMTP id 26so610062gxk.4
        for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:06:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikw9bnrurUo8n-6yUwwQ0zOv5iAOBDt=T6Nm6nkUd7vLA@mail.gmail.com>
References: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
	<532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
	<BANLkTik3mEJGXLrf_XtssfdRypm3NxBKvkhcnUpK=YXV6ux=Ag@mail.gmail.com>
	<20110629080827.GA975@phantom.vanrein.org>
	<BANLkTikw9bnrurUo8n-6yUwwQ0zOv5iAOBDt=T6Nm6nkUd7vLA@mail.gmail.com>
Date: Wed, 29 Jun 2011 09:06:11 -0700
Message-ID: <BANLkTi=2ZMmrwMrnyEyEZAEsCUQNnd5n1j8J0xzSEF=ahrJmLw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Craig Bergstrom <craigb@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, fa.linux.kernel@googlegroups.com
Cc: Rick van Rein <rick@vanrein.org>, "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

My apologies, I send this initial reply from the wrong address. Please
reply to this @google.com address.

Cheers,
CraigB

On Wed, Jun 29, 2011 at 8:28 AM, craig lkml <craig.lkml@gmail.com> wrote:
> Hi Rick,
> Thanks for your response. =A0My sincere apologies for not posting the wor=
k
> directly.
> My intention is to point interested parties to contributions that Google =
has
> made to this space through known and respected channels. =A0The cited res=
earch
> is not my research but the research of my=A0colleagues. =A0As a result, I
> hesitate to paraphrase the work as I will likely get the details wrong. =
=A0In
> any case, Shane's points are the most relevant for the discussion here.
> =A0Please refer to his post in this thread.
> In an attempt to contribute to the community as much as I can, I have
> prepared and mailed our BadRAM patch as requested. =A0In case it is not
> otherwise clear, my belief is that the ideal solution for the upstream
> kernel is a hybrid of our approaches.
> Thank you,
> CraigB
>
> On Wed, Jun 29, 2011 at 1:08 AM, Rick van Rein <rick@vanrein.org> wrote:
>>
>> Hello Craig,
>>
>> > Some folks had mentioned that they're interested in details about what
>> > we've learned about bad ram from our fleet of machines. =A0I suspect
>> > that you need ACM portal access to read this,
>>
>> I'm happy that this didn't cause a flame, but clearly this is not the
>> right response in an open environment. =A0ACM may have copyright on the
>> *form* in which you present your knowledge, but could you please poor
>> the knowledge in another form that bypasses their copyright so the
>> knowledge is made available to all?
>>
>>
>> Thanks,
>> =A0-Rick
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
