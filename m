Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E205E6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 09:08:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so22689890wmw.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:08:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u197si13968284wmu.25.2016.11.25.06.08.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 06:08:15 -0800 (PST)
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
 <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
 <296bdd6b-5c9e-0fbc-8aa1-4e95d0aff031@suse.cz>
 <ab7996b4-baf6-cf8f-6dba-006735e0587c@virtuozzo.com>
 <2ff6eee6-8828-821a-7dde-c2f68da697a5@suse.cz>
 <20161125130757.GC3439@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2ff83214-70fe-741e-bf05-fe4a4073ec3e@suse.cz>
Date: Fri, 25 Nov 2016 15:08:10 +0100
MIME-Version: 1.0
In-Reply-To: <20161125130757.GC3439@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>

On 11/25/2016 02:07 PM, Kirill A. Shutemov wrote:
>> --- a/mm/debug.c
>> +++ b/mm/debug.c
>> @@ -59,6 +59,10 @@ void __dump_page(struct page *page, const char *reason)
>>  
>>  	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
>>  
>> +	print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE,
>> +			32, (sizeof(unsigned long) == 8) ? 8 : 4,
> 
> That's a very fancy way to write sizeof(unsigned long) ;)
 
Ah, damnit, thanks.

----8<----
