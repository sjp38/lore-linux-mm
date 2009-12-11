Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 27DB56B008A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 22:38:35 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 5so119749qwc.32
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:38:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2375c9f90912101922g5b31e5c9gceeca299b9c2b656@mail.gmail.com>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
	 <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
	 <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
	 <Pine.LNX.4.64.0912100951130.31654@sister.anvils>
	 <2375c9f90912101922g5b31e5c9gceeca299b9c2b656@mail.gmail.com>
Date: Fri, 11 Dec 2009 11:38:28 +0800
Message-ID: <2375c9f90912101938hd0a358bl575a11cb9f6c5094@mail.gmail.com>
Subject: Re: An mm bug in today's 2.6.32 git tree
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 11, 2009 at 11:22 AM, Am=C3=A9rico Wang <xiyou.wangcong@gmail.c=
om> wrote:
> On Thu, Dec 10, 2009 at 5:56 PM, Hugh Dickins
> <hugh.dickins@tiscali.co.uk> wrote:
>> On Thu, 10 Dec 2009, Am=C3=A9rico Wang wrote:
>>> On Wed, Dec 9, 2009 at 10:49 PM, Hugh Dickins
>>> >
>>> > Thanks for the report. =C2=A0Not known to me.
>>> > It looks like something has corrupted the start of a pagetable.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0no, not the start
>>> > No idea what that something might be, but probably not bad RAM.
>>> >
>>> >>
>>> >> Please feel free to let me know if you need more info.
>>> >
>>> > You say you saw it twice: please post what the other occasion
>>> > showed (unless the first six lines were identical to this and it
>>> > occurred around the same time i.e. separate report of the same).
>>> >
>>>
>>> Yes, the rest are almost the same, the only difference is the 'addr'
>>> shows different addresses.
>>
>> Please post what this other occasion showed, if you still have the log.
>
> Sure, below is the whole thing.

If that doesn't look pretty, please use this one:

http://pastebin.ca/1710512

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
