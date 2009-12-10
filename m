Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C68486B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 01:59:29 -0500 (EST)
Received: by qyk15 with SMTP id 15so3269236qyk.23
        for <linux-mm@kvack.org>; Wed, 09 Dec 2009 22:59:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
	 <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
Date: Thu, 10 Dec 2009 14:59:28 +0800
Message-ID: <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
Subject: Re: An mm bug in today's 2.6.32 git tree
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 9, 2009 at 10:49 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Wed, 9 Dec 2009, Am=C3=A9rico Wang wrote:
>
>> Hi, mm experts,
>>
>> I met the following bug in the kernel from today's git tree, accidentall=
y.
>> I don't know how to reproduce it, just saw it twice when doing different
>> work. Machine is x86_64.
>>
>> Is this bug known?
>
> Thanks for the report. =C2=A0Not known to me.
> It looks like something has corrupted the start of a pagetable.
> No idea what that something might be, but probably not bad RAM.
>
>>
>> Please feel free to let me know if you need more info.
>
> You say you saw it twice: please post what the other occasion
> showed (unless the first six lines were identical to this and it
> occurred around the same time i.e. separate report of the same).
>

Yes, the rest are almost the same, the only difference is the 'addr'
shows different addresses.

The one I reported happened when I exited vim, after editing a file.
The other one happened when I did a network upload, either over
NFS or ftp or something like that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
