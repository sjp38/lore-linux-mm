Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id CA3FB6B0032
	for <linux-mm@kvack.org>; Thu, 14 May 2015 16:26:33 -0400 (EDT)
Received: by ykep21 with SMTP id p21so27760459yke.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 13:26:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o100si12925108yhp.170.2015.05.14.13.26.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 13:26:32 -0700 (PDT)
Message-ID: <555504F3.5020209@oracle.com>
Date: Thu, 14 May 2015 16:26:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11] mm: debug: formatting memory management structs
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <20150514132413.2a56b25489e0c644e68229bb@linux-foundation.org>
In-Reply-To: <20150514132413.2a56b25489e0c644e68229bb@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On 05/14/2015 04:24 PM, Andrew Morton wrote:
> On Thu, 14 May 2015 13:10:03 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> > This patch series adds knowledge about various memory management structures
>> > to the standard print functions.
>> > 
>> > In essence, it allows us to easily print those structures:
>> > 
>> > 	printk("%pZp %pZm %pZv", page, mm, vma);
>> > 
>> > This allows us to customize output when hitting bugs even further, thus
>> > we introduce VM_BUG() which allows printing anything when hitting a bug
>> > rather than just a single piece of information.
>> > 
>> > This also means we can get rid of VM_BUG_ON_* since they're now nothing
>> > more than a format string.
> A good set of example output would help people understand this proposal.

That would be the equivalent of doing:

	dump_page(page);
	dump_mm(mm);
	dump_vma(vma);

I'll add a few example usages in.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
