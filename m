Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EBDD0900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 04:05:41 -0400 (EDT)
Date: Fri, 24 Jun 2011 08:05:35 +0000
From: Rick van Rein <rick@vanrein.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110624080535.GA19966@phantom.vanrein.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de> <20110623170014.GN3263@one.firstfloor.org> <987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com> <BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Craig Bergstrom <craigb@google.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rick@vanrein.org" <rick@vanrein.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

Hi Craig,

> We (Google) are working on a data-driven answer for this question.  I know
> that there has been some analysis on this topic on the past, but I don't
> want to speculate until we've had some time to put all the pieces together.

The easiest way to do this could be to take the algorithm from Memtest86
and apply it to your data, to see if it finds suitable patterns for the
cases tried.

By counting bits set to zero in the masks, you could then determine how
'tight' they are.  A mask with all-ones covers one memory page; each
zero bit in the mask (outside of the CPU's page size) doubles the number
of pages covered.

You can ignore the address over which the mask is applied, although you
would then be assuming that all the pages covered by the mask are indeed
filled with RAM.

You would want to add the figures for the different masks.

I am very curious about your findings.  Independently of those, I am in
favour of a patch that enables longer e820 tables if it has no further
impact on speed or space.


Cheers,
 -Rick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
