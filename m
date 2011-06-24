Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EFF61900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 21:22:23 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p5O1MJE0025146
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:22:20 -0700
Received: from gxk9 (gxk9.prod.google.com [10.202.11.9])
	by kpbe13.cbf.corp.google.com with ESMTP id p5O1MIOg032401
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:22:18 -0700
Received: by gxk9 with SMTP id 9so1229872gxk.12
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:22:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110624010835.GQ3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110623133950.GB28333@srcf.ucam.org>
	<4E0348E0.7050808@kpanic.de>
	<20110623141222.GA30003@srcf.ucam.org>
	<4E035DD1.1030603@kpanic.de>
	<20110623170014.GN3263@one.firstfloor.org>
	<987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
	<BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
	<20110624010835.GQ3263@one.firstfloor.org>
Date: Thu, 23 Jun 2011 18:22:17 -0700
Message-ID: <BANLkTinuuX+Ja64VJNfRbyf5NR+ga9PLnQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Craig Bergstrom <craigb@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rick@vanrein.org" <rick@vanrein.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

On Thu, Jun 23, 2011 at 6:08 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> We (Google) are working on a data-driven answer for this question. =A0I =
know
>> that there has been some analysis on this topic on the past, but I don't
>> want to speculate until we've had some time to put all the pieces togeth=
er.
>> =A0Stay tuned for specifics.
>
> It would be also good if you posted your kernel patches.
>
> It's highly unusual -- to say the least -- to let someone's openly
> developed and posted patchkit compete with someone's else secret
> internal solution for review purposes.

Hi Andi,

This is quite hard to argue with.  Let me see what I can do.

Cheers,
CraigB

> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
