Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD424900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 20:59:12 -0400 (EDT)
Date: Fri, 24 Jun 2011 02:59:07 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110624005907.GP3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de> <4E036A2D.1060402@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E036A2D.1060402@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net

On Thu, Jun 23, 2011 at 09:30:37AM -0700, H. Peter Anvin wrote:
> On 06/23/2011 08:37 AM, Stefan Assmann wrote:
> > 
> > According to Rick's reply in this thread a damaged row in a DIMM can
> > easily cause a few thousand entries in the e820 table because it doesn't
> > handle patterns. So the question I'm asking is, is it acceptable to
> > have an e820 table with thousands maybe ten-thousands of entries?
> > I really have no idea of the implications, maybe somebody else can
> > comment on that.
> > 
> 
> Given that that is what actually ends up happening in the kernel at some
> point anyway, 

hwpoison can poison most pages without any lists.  Read Stefan's original patch.

The only thing that needs list really is conflict handling with
early allocations.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
