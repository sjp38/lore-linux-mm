Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8DFD6B0036
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 05:38:33 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so1228754eek.24
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 02:38:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si3033397eel.49.2014.01.09.02.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 02:38:28 -0800 (PST)
Message-ID: <52CE7C21.4060300@suse.cz>
Date: Thu, 09 Jan 2014 11:38:25 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
References: <52B88F6E.8070909@oracle.com> <20131223200255.GA18521@node.dhcp.inet.fi> <52B8AAFD.5090401@oracle.com> <52C819E2.8090509@oracle.com>
In-Reply-To: <52C819E2.8090509@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 01/04/2014 03:25 PM, Sasha Levin wrote:
> On 12/23/2013 04:28 PM, Sasha Levin wrote:
>> On 12/23/2013 03:02 PM, Kirill A. Shutemov wrote:
>>>> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
>>> Could you dump_page() on the bug?
>>
>> [  469.007946] page:ffffea0005bd8000 count:3 mapcount:0 mapping:ffff8800bcd3d171 index: 0x7fca81000
>> [  469.009362] page flags: 0x2afffff80090018(uptodate|dirty|swapcache|swapbacked)
>
> Ping? It still shows up in 3.13-rc6.

Could you verify if a version before split PMD locks is affected or not? 
I.e. 3.12 (IIRC)? I've checked if there can be race with THP splitting 
and it seems there shouldn't be thanks to pmd_lock() protection. So that 
could be a candidate. Given the recent trinity improvements it would be 
good to determine if it's a new bug or another years old one...

Thanks,
Vlastimil

> Thanks,
> Sasha
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
