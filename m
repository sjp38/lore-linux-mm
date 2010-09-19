Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5997D6B007E
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 11:03:18 -0400 (EDT)
Received: by eyh5 with SMTP id 5so2012520eyh.14
        for <linux-mm@kvack.org>; Sun, 19 Sep 2010 08:03:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=-Npp=YWqEG6YpQ+EzP0PtMacJaB18roDFZ40E@mail.gmail.com>
References: <AANLkTi=-Npp=YWqEG6YpQ+EzP0PtMacJaB18roDFZ40E@mail.gmail.com>
Date: Sun, 19 Sep 2010 20:33:16 +0530
Message-ID: <AANLkTinHvMZJyKYjCoGecPRV_4U=S8y5_WHN1z8Uq33w@mail.gmail.com>
Subject: setting and removing break-point from within kernel
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

=A0 =A0 =A0 =A0 I am trying to debug =A0a subtle =A0timing-dependent =A0bug=
 in kernel.

I found that =A0if =A0I could set up =A0a break-point =A0from within =A0ker=
nel
at run-time, this =A0would help.

The condition to trigger is
"If =A00 is written =A0at =A0virtual address =A00xCEC8F004 , then stop".

The address is on kernel-stack

My =A0SOC has a onchip =A0JTAG-based =A0debug block.

What I have in mind =A0is =A0to do as =A0below -

signed long __sched schedule_timeout(signed long timeout)
{
=A0struct timer_list timer;
=A0unsigned long expire;
// some =A0kernel code

// setup =A0conditional break-point

// some =A0kernel code =A0runs here
// some =A0kernel code
// some =A0kernel code

// =A0remove =A0the break-point

// some =A0kernel code =A0runs here

}

     Has anyone tried this ?
     Any ideas ?
                                       Thanks
                                       shankar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
