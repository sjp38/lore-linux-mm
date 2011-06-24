Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DCC8590023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 12:16:35 -0400 (EDT)
Message-ID: <4E04B848.6000908@zytor.com>
Date: Fri, 24 Jun 2011 09:16:08 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de> <20110623170014.GN3263@one.firstfloor.org> <987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com> <BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com> <20110624080535.GA19966@phantom.vanrein.org>
In-Reply-To: <20110624080535.GA19966@phantom.vanrein.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: Craig Bergstrom <craigb@google.com>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

On 06/24/2011 01:05 AM, Rick van Rein wrote:
> 
> I am very curious about your findings.  Independently of those, I am in
> favour of a patch that enables longer e820 tables if it has no further
> impact on speed or space.
> 

That is already in the mainline kernel, although only if fed from the
boot loader (it was developed in the context of mega-NUMA machines); the
stub fetching from INT 15h doesn't use this at the moment.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
