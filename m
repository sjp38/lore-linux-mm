Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 393C26B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:25:52 -0400 (EDT)
Message-ID: <4A2028BD.8050408@redhat.com>
Date: Fri, 29 May 2009 14:26:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
References: <200905271012.668777061@firstfloor.org> <20090527201226.CCCBB1D028F@basil.firstfloor.org> <20090527221510.5e418e97@lxorguk.ukuu.org.uk> <20090528075416.GY1065@one.firstfloor.org> <4A2008F0.1070304@redhat.com> <20090529163757.GX1065@one.firstfloor.org> <4A200E98.20306@redhat.com> <20090529182440.GY1065@one.firstfloor.org>
In-Reply-To: <20090529182440.GY1065@one.firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Fri, May 29, 2009 at 12:34:32PM -0400, Rik van Riel wrote:
>>> They should just check for poisoned pages. 
>> #define PagePoisoned(page) (PageReserved(page) && PageWriteback(page))
> 
> I don't know what the point of that would be. An exercise in code
> obfuscation?

Saving a page flag.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
