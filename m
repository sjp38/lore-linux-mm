Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A8CEB6B0023
	for <linux-mm@kvack.org>; Wed,  4 May 2011 06:25:47 -0400 (EDT)
Received: by iwg8 with SMTP id 8so1200322iwg.14
        for <linux-mm@kvack.org>; Wed, 04 May 2011 03:25:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimLd-qY-OeKqnf2EoTfvAHWQZVchw@mail.gmail.com>
References: <BANLkTimLd-qY-OeKqnf2EoTfvAHWQZVchw@mail.gmail.com>
Date: Wed, 4 May 2011 11:25:45 +0100
Message-ID: <BANLkTi=xz4w3p4bc5T4-YvkC3tYdwKhWGA@mail.gmail.com>
Subject: Re: [ARM]crash on 2.6.35.11
From: Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-arm-request@lists.arm.linux.org.uk, linux-kernel@vger.kernel.org

On 4 May 2011 11:09, naveen yadav <yad.naveen@gmail.com> wrote:
> We are running linux kernel 2.6.35.11 on Cortex a-8. when I run a
> simple program expect to give oom.
> =C2=A0But it crash with following crash log

Could you post the full kernel boot log and .config file?

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
