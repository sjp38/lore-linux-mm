Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 68064900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:12:58 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Jun 2011 10:12:55 -0700
Subject: RE: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
 <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de>
 <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de>
 <20110623170014.GN3263@one.firstfloor.org>
In-Reply-To: <20110623170014.GN3263@one.firstfloor.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rick@vanrein.org" <rick@vanrein.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

> I don't think it makes sense to handle something like that with a list.
> The compact representation currently in badram is great for that.

I'd tend to agree here.  Rick has made a convincing argument that there
are significant numbers of real world cases where a defective row/column
in a DIMM results in a predictable pattern of errors.  The ball is now
in Google's court to take a look at their systems that have high numbers
of errors to see if they can actually be described by a small number
of BadRAM patterns as Rick has claimed.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
