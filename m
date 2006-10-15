Message-ID: <4531E946.5070503@yahoo.com.au>
Date: Sun, 15 Oct 2006 17:54:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061007105758.14024.70048.sendpatchset@linux.site> <5c77e7070610120456t1bdaa95cre611080c9c953582@mail.gmail.com> <20061012120735.GA20191@wotan.suse.de> <200610141528.50542.ioe-lkml@rameria.de>
In-Reply-To: <200610141528.50542.ioe-lkml@rameria.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: Nick Piggin <npiggin@suse.de>, Carsten Otte <cotte.de@gmail.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

Ingo Oeser wrote:
> Hi Nick,
> 
> On Thursday, 12. October 2006 14:07, Nick Piggin wrote:
> 
>>Actually, filemap_xip needs some attention I think... if xip files
>>can be truncated or invalidated (I assume they can), then we need to
>>lock the page, validate that it is the correct one and not truncated,
>>and return with it locked.
> 
> 
> ???
> 
> Isn't XIP for "eXecuting In Place" from ROM or FLASH?

Yes, I assume so. It seems that it isn't restricted to executing, but
is basically a terminology to mean that it bypasses the pagecache.

> How to truncate these? I thought the whole idea of
> XIP was a pure RO mapping?

Well, not filemap_xip.

> 
> They should be valid from mount to umount.
> 
> Regards
> 
> Ingo Oeser, a bit puzzled about that...

See mm/filemap_xip.c:xip_file_write, xip_truncate_page.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
