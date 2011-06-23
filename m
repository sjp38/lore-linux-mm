Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11AF6900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:00:20 -0400 (EDT)
Date: Thu, 23 Jun 2011 19:00:14 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110623170014.GN3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E035DD1.1030603@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net

> According to Rick's reply in this thread a damaged row in a DIMM can
> easily cause a few thousand entries in the e820 table because it doesn't
> handle patterns. So the question I'm asking is, is it acceptable to
> have an e820 table with thousands maybe ten-thousands of entries?
> I really have no idea of the implications, maybe somebody else can
> comment on that.

I don't think it makes sense to handle something like that with a list.
The compact representation currently in badram is great for that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
