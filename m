Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D77726B016B
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 07:33:06 -0500 (EST)
Received: by pwj9 with SMTP id 9so1143325pwj.14
        for <linux-mm@kvack.org>; Sat, 13 Mar 2010 04:33:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003130149080.22823@chino.kir.corp.google.com>
References: <1268456515-8557-1-git-send-email-user@bob-laptop>
	 <alpine.DEB.2.00.1003130149080.22823@chino.kir.corp.google.com>
Date: Sat, 13 Mar 2010 20:33:04 +0800
Message-ID: <cf18f8341003130433r474616bfnbb9524a77e815ac1@mail.gmail.com>
Subject: Re: [PATCH] mempolicy: remove redundant code
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sat, Mar 13, 2010 at 5:52 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Sat, 13 Mar 2010, Bob Liu wrote:
>
>> diff --git a/mempolicy.c b/mempolicy.c
>> index bda230e..b6fbcbd 100644
>> --- a/mempolicy.c
>> +++ b/mempolicy.c
>
> What git tree is this? =C2=A0Your patch needs to change mm/mempolicy.c.
>

It's linux-next.
Yeah, I forgot the mm/ path, sorry. I need send it again or just reply
in this mail?
Thanks a lot!

> Please clone Linus' repository and then create a patch against that:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git clone git://git.kernel.org/pub/scm/linux/k=
ernel/git/torvalds/linux-2.6.git
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cd linux-2.6
> =C2=A0 =C2=A0 =C2=A0 =C2=A0<change mm/mempolicy.c>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0<compile, test>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git commit -a
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git format-patch HEAD^
>
> and send the .patch file.
>
> Thanks.
>

--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
