Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE966B016A
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 04:38:44 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so5339840bkb.14
        for <linux-mm@kvack.org>; Mon, 05 Sep 2011 01:38:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ8eaTxPRbEGbFtME9HEnR=vUtvCOzkDoRA51AudpcPKcGeOvQ@mail.gmail.com>
References: <CAJ8eaTxPRbEGbFtME9HEnR=vUtvCOzkDoRA51AudpcPKcGeOvQ@mail.gmail.com>
Date: Mon, 5 Sep 2011 14:08:41 +0530
Message-ID: <CAJ8eaTxaUfdX7DiXuAA=18u_m+ESA7fwwkw1zCSF9HrsoC-ydQ@mail.gmail.com>
Subject: Re: Kernel crash (2.6.35.13)
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk

Adding linux-arm

On Thu, Sep 1, 2011 at 4:10 PM, naveen yadav <yad.naveen@gmail.com> wrote:
> Dear All,
>
> I am running a simple test program that just do malloc and memset. The
> testprogram is run using below attached script
>
> while true
> do
> ./stress &
> ./stress &
> ./stress &
> ./stress &
> sleep 1
> done
>
>
> we got this issue on embedded Target.
>
> After analysis we found that most of task(stress_application) is in D
> for uninterruptible sleep.
> application =A0 =A0 =A0 =A0 =A0 state
>
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> sleep =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 D
>
> So I observe after 10-15 min Kernel crash with
>
> Kernel panic - not syncing: Out of memory and no killable processes...
>
>
> I am attaching Kernel Crash log + Test application.
>
> Thanks
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
