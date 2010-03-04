Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35CCB6B004D
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:42:57 -0500 (EST)
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o24IgtXS022494
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 11:42:55 -0700 (MST)
Received: from zin33exm20.fsl.freescale.net (zin33exm20.ap.freescale.net [10.232.192.5])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id o24Ip37j028178
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 12:51:04 -0600 (CST)
MIME-Version: 1.0
Content-class: 
From: "Kalra Ashish-B00888" <B00888@freescale.com>
Message-ID: <292701cabbca$7f5e1ef2$2303d30a@fsl.freescale.net>
Subject: RE: Linux kernel - Libata bad block error handling to user mode  program
Date: Fri, 5 Mar 2010 00:10:42 +0530
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset="utf-8"
Sender: owner-linux-mm@kvack.org
To: Mark Lord <kernel@teksavvy.com>, foo saa <foosaa@gmail.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



Sent from my HTC

-----Original Message-----
From: Mark Lord <kernel@teksavvy.com>
Sent: 04 March 2010 11:20 PM
To: foo saa <foosaa@gmail.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>; Andrew Morton <akpm@linux-foun=
dation.org>; linux-kernel@vger.kernel.org <linux-kernel@vger.kernel.org>; l=
inux-ide@vger.kernel.org <linux-ide@vger.kernel.org>; Jens Axboe <jens.axbo=
e@oracle.com>; linux-mm@kvack.org <linux-mm@kvack.org>
Subject: Re: Linux kernel - Libata bad block error handling to user mode  p=
rogram

On 03/04/10 10:33, foo saa wrote:
..
> hdparm is good, but I don't want to use the internal ATA SECURE ERASE
> because I can never get the amount of bad sectors the drive had.
..

Oh.. but isn't that information in the S.M.A.R.T. data ??

You'll not find the bad sectors by writing -- a true WRITE nearly never
reports a media error.  Instead, the drive simply remaps to a good sector
on the fly and returns success.

Generally, only READs report media errors.

Cheers
--
To unsubscribe from this list: send the line "unsubscribe linux-ide" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
