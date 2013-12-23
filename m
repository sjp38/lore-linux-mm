Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 085FF6B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 16:28:37 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so5758940qen.33
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 13:28:37 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r6si15958405qaj.175.2013.12.23.13.28.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 13:28:36 -0800 (PST)
Message-ID: <52B8AAFD.5090401@oracle.com>
Date: Mon, 23 Dec 2013 16:28:29 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
References: <52B88F6E.8070909@oracle.com> <20131223200255.GA18521@node.dhcp.inet.fi>
In-Reply-To: <20131223200255.GA18521@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 12/23/2013 03:02 PM, Kirill A. Shutemov wrote:
>> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
> Could you dump_page() on the bug?

[  469.007946] page:ffffea0005bd8000 count:3 mapcount:0 mapping:ffff8800bcd3d171 index: 0x7fca81000
[  469.009362] page flags: 0x2afffff80090018(uptodate|dirty|swapcache|swapbacked)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
