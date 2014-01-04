Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f175.google.com (mail-gg0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id A4F5D6B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 09:25:46 -0500 (EST)
Received: by mail-gg0-f175.google.com with SMTP id u2so3212222ggn.6
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 06:25:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p5si7357082yho.234.2014.01.04.06.25.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 06:25:45 -0800 (PST)
Message-ID: <52C819E2.8090509@oracle.com>
Date: Sat, 04 Jan 2014 09:25:38 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
References: <52B88F6E.8070909@oracle.com> <20131223200255.GA18521@node.dhcp.inet.fi> <52B8AAFD.5090401@oracle.com>
In-Reply-To: <52B8AAFD.5090401@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 12/23/2013 04:28 PM, Sasha Levin wrote:
> On 12/23/2013 03:02 PM, Kirill A. Shutemov wrote:
>>> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
>> Could you dump_page() on the bug?
>
> [  469.007946] page:ffffea0005bd8000 count:3 mapcount:0 mapping:ffff8800bcd3d171 index: 0x7fca81000
> [  469.009362] page flags: 0x2afffff80090018(uptodate|dirty|swapcache|swapbacked)

Ping? It still shows up in 3.13-rc6.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
