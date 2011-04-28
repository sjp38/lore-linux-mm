Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 06BB76B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:44:19 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Apr 2011 10:44:17 -0700
Subject: RE: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
Message-ID: <987664A83D2D224EAE907B061CE93D5301C51BF009@orsmsx505.amr.corp.intel.com>
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>
 <1303921007-1769-3-git-send-email-sassmann@kpanic.de>
 <20110427211258.GQ16484@one.firstfloor.org> <4DB90A66.3020805@kpanic.de>
 <20110428150821.GT16484@one.firstfloor.org> <4DB98D13.1050107@kpanic.de>
In-Reply-To: <4DB98D13.1050107@kpanic.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>, Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rick@vanrein.org" <rick@vanrein.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>

> BadRAM patterns might often mark non-consecutive pages so outputting
> ranges could be more verbose than what we have now. I'll try to think
> of something to minimize log output.

How about printing the pattern together with a count of pages affected:

badram: addr=3Dfoo mask=3Dbar (1024 pages =3D 4MB marked unusable)

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
