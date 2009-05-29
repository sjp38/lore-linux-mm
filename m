Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B4DCC6B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:35:26 -0400 (EDT)
Date: Fri, 29 May 2009 20:42:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
Message-ID: <20090529184243.GA1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201226.CCCBB1D028F@basil.firstfloor.org> <20090527221510.5e418e97@lxorguk.ukuu.org.uk> <20090528075416.GY1065@one.firstfloor.org> <4A2008F0.1070304@redhat.com> <20090529163757.GX1065@one.firstfloor.org> <4A200E98.20306@redhat.com> <20090529182440.GY1065@one.firstfloor.org> <4A2028BD.8050408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A2028BD.8050408@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 29, 2009 at 02:26:05PM -0400, Rik van Riel wrote:
> Andi Kleen wrote:
> >On Fri, May 29, 2009 at 12:34:32PM -0400, Rik van Riel wrote:
> >>>They should just check for poisoned pages. 
> >>#define PagePoisoned(page) (PageReserved(page) && PageWriteback(page))
> >
> >I don't know what the point of that would be. An exercise in code
> >obfuscation?
> 
> Saving a page flag.

It seems pointless to me. 64bit has enough space and 32bit just puts
less node bits into ->flags.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
