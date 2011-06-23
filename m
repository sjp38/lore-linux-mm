Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D380900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:31:08 -0400 (EDT)
Message-ID: <4E036A2D.1060402@zytor.com>
Date: Thu, 23 Jun 2011 09:30:37 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de>
In-Reply-To: <4E035DD1.1030603@kpanic.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net

On 06/23/2011 08:37 AM, Stefan Assmann wrote:
> 
> According to Rick's reply in this thread a damaged row in a DIMM can
> easily cause a few thousand entries in the e820 table because it doesn't
> handle patterns. So the question I'm asking is, is it acceptable to
> have an e820 table with thousands maybe ten-thousands of entries?
> I really have no idea of the implications, maybe somebody else can
> comment on that.
> 

Given that that is what actually ends up happening in the kernel at some
point anyway, I don't see why it would matter.

The bubble sort has to go, but quite frankly stress-testing the range
handling isn't a bad thing.
	
	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
