Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 89B966B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 10:21:31 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1450595iyh.14
        for <linux-mm@kvack.org>; Wed, 04 May 2011 07:21:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik17MGwWwFb=CzBduFy9Mn-Ze+ptA@mail.gmail.com>
References: <BANLkTimLd-qY-OeKqnf2EoTfvAHWQZVchw@mail.gmail.com>
	<BANLkTi=xz4w3p4bc5T4-YvkC3tYdwKhWGA@mail.gmail.com>
	<BANLkTik17MGwWwFb=CzBduFy9Mn-Ze+ptA@mail.gmail.com>
Date: Wed, 4 May 2011 15:21:26 +0100
Message-ID: <BANLkTi=WYk3_wQ8R1x9JD3-A+asO3cyo4Q@mail.gmail.com>
Subject: Re: [ARM]crash on 2.6.35.11
From: Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

(fixing up the linux-arm-kernel list address)

On 4 May 2011 14:18, naveen yadav <yad.naveen@gmail.com> wrote:
> On Wed, May 4, 2011 at 3:55 PM, Catalin Marinas <catalin.marinas@arm.com>=
 wrote:
>> On 4 May 2011 11:09, naveen yadav <yad.naveen@gmail.com> wrote:
>>> We are running linux kernel 2.6.35.11 on Cortex a-8. when I run a
>>> simple program expect to give oom.
>>> =C2=A0But it crash with following crash log
>>
>> Could you post the full kernel boot log and .config file?
>
> Pls find attached log

It looks like a problem with the memory configuration on your board.
You have sparsemem sections which are not fully populated. The
mainline kernel still has problems in this area.

You can try this patch (not sure it applies cleanly on 2.6.35 but it's
not difficult to fix):

http://article.gmane.org/gmane.linux.ports.arm.kernel/112994

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
