Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3786B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:46:17 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 65so197290028pff.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:46:17 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id fd9si3036734pac.80.2016.01.06.09.46.16
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 09:46:16 -0800 (PST)
Subject: Re: [PATCH 22/32] x86, pkeys: dump PTE pkey in /proc/pid/smaps
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190619.BA65327A@viggo.jf.intel.com> <568BC5FA.2080800@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <568D52E7.1060602@sr71.net>
Date: Wed, 6 Jan 2016 09:46:15 -0800
MIME-Version: 1.0
In-Reply-To: <568BC5FA.2080800@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On 01/05/2016 05:32 AM, Vlastimil Babka wrote:
> On 12/14/2015 08:06 PM, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> $SUBJ is a bit confusing in that it's dumping stuff from VMA, not PTE's?

Yeah, absolutely.  That's a relic from when I thought I'd need to be
walking the page tables to figure this out.  I'll update it.

> It could be also useful to extend dump_vma() appropriately. Currently
> there are no string translations for the new "flags" (but one can figure
> it out from the raw value). But maybe we should print pkey separately in
> dump_vma() as you do here. I have a series in flight [1] that touches
> dump_vma() and the flags printing in general, so to avoid conflicts,
> handling pkeys there could wait. But mentioning it now for less chance
> of being forgotten...
> 
> [1] https://lkml.org/lkml/2015/12/18/178 - a previous version is in
> mmotm and this should replace it after 4.5-rc1

Ahhh, very nice.  I'll go back and add support for it once your patch lands.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
